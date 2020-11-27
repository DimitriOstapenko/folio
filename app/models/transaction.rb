class Transaction < ApplicationRecord
  belongs_to :position
  default_scope -> { order(created_at: :desc) }

  validates :qty, presence: true, numericality: true, if: Proc.new { |tr| (tr.tr_type != DRIP_TR)}
  validates :tr_type, presence: true

  before_validation :set_attributes!
#  before_validation :set_tr_type!
  after_save :add_cash_div, if: Proc.new { |tr| (tr.tr_type == DRIP_TR)}
  validate :validate_tr

#  def set_tr_type!
#    self.tr_type = CASH_TR if self.position.is_cash?
#  end

  def set_attributes!
    self.qty ||= 0.0     # cash div
    self.price ||= 0.0   # cash div
    case self.tr_type
    when BUY_TR
      self.qty = self.qty.abs
    when SELL_TR
      self.qty = -self.qty.abs
    when DRIP_TR  # Cash dividend
      self.qty = self.qty.abs
    when CASH_TR
      self.price = 1.0
      self.fees = 0.0
    else 
      errors.add(:'Transaction Type', "is invalid")
    end
  end

# add remaining cash from dividend reinvestment  
  def add_cash_div
    cash = self.cashdiv - (self.qty * self.price)  # in portfolio currency
    if cash > 0
      cash_position = self.base_cash_position
      tr = cash_position.transactions.create(tr_type: CASH_TR, qty: cash, date: self.date, note: 'Cash from DRIP') if cash_position
      tr.position.recalculate
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
    if self.drip? && self.qty.zero?
      self.cashdiv
    else
      self.price * self.qty rescue 0
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
  
  def drip?
    self.tr_type == DRIP_TR
  end

# Recalculate position and save it along with transaction  
  def recalculate
    return unless self.qty
    self.position.qty += self.qty if self.qty.present?
    case self.tr_type
    when BUY_TR 
      self.position.acb += self.amount + self.fees
      # Adjust cash
      cash_pos = self.base_cash_position
      qty = acb = -(self.amount + self.fees)
      cash_pos.transactions.create(tr_type: CASH_TR, qty: qty, acb: acb, price: 1, ttl_qty: cash_pos.qty+qty, date: self.date, note: "bought #{self.qty} #{self.position.symbol} @ #{self.price} + #{self.fees} in fees" )
      cash_pos.update_attribute(:qty, cash_pos.qty + qty)
    when DRIP_TR
      self.position.acb += self.amount if self.qty.present?
    when SELL_TR
      self.position.acb += self.qty * self.position.avg_price
      self.gain = -self.amount - self.fees + self.position.avg_price * self.qty
    when CASH_TR
      self.position.acb += self.qty
      self.gain = 0.0
    end
    self.acb = self.position.acb
    self.ttl_qty = self.position.qty
    self.position.save!
  end

  def validate_tr
    case self.tr_type
    when SELL_TR
      errors.add(:qty, ': Insufficient number of shares') if self.position.qty < 0
    when DRIP_TR
      cash = self.cashdiv - (self.qty * self.price)  # in portfolio currency
      errors.add(:cashdiv, ': Insufficient amount') if cash < 0
    end
  end

end
