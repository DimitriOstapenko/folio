class Transaction < ApplicationRecord
  belongs_to :position
  default_scope -> { order(date: :desc) }

  validates :qty, presence: true, numericality: true, if: Proc.new { |tr| (tr.tr_type != DIV_TR)}
  validates :tr_type, presence: true

  before_validation :set_attributes!
  validate :validate_tr

  after_save :redo_position
  after_destroy :redo_position

  def redo_position
    self.position.recalculate
  end

  def set_attributes!
    self.qty ||= 0.0     # cash div
    self.price ||= 0.0   # cash div
    self.date ||= Time.now
    case self.tr_type
    when BUY_TR
      self.qty = self.qty.abs
      self.cash = -(self.amount + self.fees)
      self.gain = 0
    when SELL_TR
      self.qty = -self.qty.abs
      self.cash = self.amount + self.fees
    when DIV_TR 
      self.qty = self.qty.abs
    when CASH_TR
      self.price = 1.0
      self.fees = 0.0
      self.cash = self.qty
    else 
      errors.add(:'Transaction Type', "is invalid")
    end
  end

# Find cash position in current position's base currency, if any  
  def base_cash_position
    self.position.portfolio.positions.find_by(symbol: self.position.currency_str) rescue nil
  end

  def locale
    self.position.currency == EUR ? :fr : :ca 
  end

  def tr_type_str
    TRANSACTION_TYPES.invert[self.tr_type].to_s rescue nil
  end

  def amount
    if self.dividend? && self.qty.zero?
      self.cash.abs
    else
      (self.price * self.qty).abs rescue 0
    end
  end

  def acb_share
    self.acb / self.ttl_qty rescue 0
  end

  def sell?
    self.tr_type == SELL_TR
  end
  
  def buy?
    self.tr_type == BUY_TR
  end
  
  def dividend?
    self.tr_type == DIV_TR
  end

# not used  
# Recalculate position and save it along with transaction  
  def recalculate_prev
    return unless self.qty
    self.position.qty += self.qty if self.qty.present?
    cash_pos = self.base_cash_position

    case self.tr_type
    when BUY_TR 
      self.position.acb += self.amount + self.fees
      cash_pos.update_attribute(:qty, cash_pos.qty + self.cash) if cash_pos

    when SELL_TR
      self.position.acb += self.qty * self.position.avg_price
      self.gain = self.amount - self.fees + self.position.avg_price * self.qty
      cash_pos.update_attribute(:qty, cash_pos.qty + self.cash) if cash_pos

    when DIV_TR
      self.position.acb += self.amount if self.qty.present? # do not include cash dividend
      cash = self.cash - (self.amount + self.fees)  # in portfolio currency
      cash_pos.transactions.create(tr_type: CASH_TR, cash: cash, date: self.date, note: 'Cash from DRIP') if cash > 0 && cash_pos
      cash_pos.recalculate

    when CASH_TR
      self.position.acb += self.cash 
      self.gain = 0.0
    end

    self.acb = self.position.acb
    self.ttl_qty = self.position.qty
    self.position.save!
  end


# Fill missing fields in the transaction   
  def recalculate(prev=nil)
    return if self.frozen?
    return unless self.qty
    prev_ttl_qty = prev.present? ? prev.ttl_qty : 0
    prev_acb = prev.present? ? prev.acb : 0

    logger.debug ( "*********** #{prev_ttl_qty} : #{self.qty}" )
    case self.tr_type
    when BUY_TR
      self.ttl_qty = prev_ttl_qty + self.qty
      self.acb = prev_acb + self.amount + self.fees

    when SELL_TR
      self.ttl_qty = prev_ttl_qty + self.qty 
      self.acb = prev_acb + prev_acb/prev_ttl_qty * self.qty
      self.gain = self.amount - self.acb - self.fees

    when CASH_TR
      self.ttl_qty = prev_ttl_qty + self.qty 
    end
  end

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
