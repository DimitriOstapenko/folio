class Transaction < ApplicationRecord
  belongs_to :position
  default_scope -> { order(date: :desc) }

  validates :qty, presence: true, numericality: true, if: Proc.new { |tr|  !tr.dividend? } 
  validates :tr_type, presence: true, inclusion: { in: TRANSACTION_TYPES.values, message: "%{value} is invalid transaction type"}

  before_validation :set_attributes!
#  validate :validate_tr

  after_create :add_dividend, if: Proc.new { |tr| tr.dividend? }

  def add_dividend
    if self.qty > 0  # Add cash tr [and buy tr], then add div
      cash = -(self.qty * self.price + self.fees)
      buy_tr = self.position.transactions.create!(tr_type: BUY_TR, qty: self.qty, price: self.price, cash: cash)
    end
    self.update!( qty: 0, price: 0) #, ttl_qty: self.position.qty, acb: self.position.acb )
  end

  def set_attributes!
    self.acb ||= 0.0
    self.qty ||= 0.0     
    self.fees ||= 0.0
    self.price ||= 0.0  
    self.date ||= Time.now

    case self.tr_type
    when BUY_TR
      self.qty = self.qty.abs
      self.cash =  -(self.amount + self.fees)  
      self.ttl_cash = self.cash if self.position.transactions.empty?
      self.gain = 0
      self.note = "bought #{qty} #{self.position.symbol} @ #{sprintf("%.2f", self.price)}" if self.note.blank?

    when SELL_TR
      self.qty = -self.qty.abs
      self.cash = self.amount - self.fees
      self.note = "sold #{qty.abs} #{self.position.symbol} @ #{self.price}" if self.note.blank?

    when DIV_TR 
      self.note = "#{self.position.symbol} dividend"

    when CASH_TR
      self.price = 1.0
      self.acb = self.cash
#      logger.debug ( "*********** cash tr: #{self.inspect}" )
    else 
      errors.add(:'Transaction Type', "is invalid")
    end
  end

# Find cash position in current position's base currency, if any  
  def base_cash_position
    self.position.portfolio.positions.find_by(symbol: self.position.currency_str) rescue nil
  end

  def locale
    self.position.locale
  end

  def tr_type_str
    TRANSACTION_TYPES.invert[self.tr_type].to_s rescue nil
  end

  def amount
    if self.cash?
      self.cash
    else
      (self.price * self.qty).abs rescue 0
    end
  end

  def acb_share
    return self.ttl_acb / self.ttl_qty if self.ttl_acb && self.ttl_qty > 0
    return 0
  end

# Transaction fx rate   
  def fx_rate
    self.position.fx_rate rescue 1 
  end

  def cash_base
    self.cash * self.fx_rate rescue nil
  end

  def buy?
    self.tr_type == BUY_TR
  end

  def sell?
    self.tr_type == SELL_TR
  end
  
  def cash?
    self.tr_type == CASH_TR
  end
  
  def dividend?
    self.tr_type == DIV_TR
  end

# Recalculate totals in the transaction based on previous transaction  
  def recalculate(prev=nil)
    return if self.frozen?
    return unless self.qty
    prev_ttl_qty = prev_ttl_cash = prev_ttl_acb = 0
    if prev.present?
      prev_ttl_qty = prev.ttl_qty
      prev_ttl_cash = prev.ttl_cash 
      prev_ttl_acb = prev.ttl_acb
    end

    case self.tr_type
    when BUY_TR
      self.ttl_qty = prev_ttl_qty + self.qty
      self.ttl_cash = prev_ttl_cash + self.cash
      self.acb = self.amount + self.fees
      self.ttl_acb = prev_ttl_acb + self.acb
#      logger.debug ( "*********** buy tr: #{self.inspect}" )

    when SELL_TR
      self.ttl_qty = prev_ttl_qty + self.qty 
      self.ttl_cash = prev_ttl_cash + self.cash 
      avg_price = prev_ttl_acb/prev_ttl_qty rescue self.price
      self.acb = avg_price * self.qty
      self.ttl_acb = prev_ttl_acb + self.acb 
      self.gain = self.amount - avg_price * self.qty.abs - self.fees
#      logger.debug("##### sell tr: amount: #{self.amount} tr: #{self.inspect}")

    when CASH_TR
#      logger.debug ( "*********** cash tr: #{self.inspect}" )
      self.ttl_cash = self.ttl_acb = prev_ttl_cash + self.cash 
    
    when DIV_TR # not called from positions
#      logger.debug ( "*********** div tr: #{self.inspect}" )
    end
    self.save!

  end

# No short sales; dividend amount sanity  
  def validate_tr
    case self.tr_type
    when SELL_TR
      errors.add(:qty, ': Insufficient number of shares') if self.position.qty < 0
    when DIV_TR
      cash = self.cash - (self.qty * self.price)  # in portfolio currency
      errors.add(:cash, ': Insufficient amount') if cash < 0
    end
  end

end
