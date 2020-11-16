class Transaction < ApplicationRecord
  belongs_to :position
  default_scope -> { order(created_at: :desc) }

  validates :qty, presence: true, numericality: true, if: Proc.new { |tr| (tr.tr_type != DRIP_TR)}
  validates :tr_type, presence: true

  before_create :set_attributes!
  before_validation :set_tr_type!
  validate :validate_tr

  def set_tr_type!
    self.tr_type = CASH_TR if self.position.is_cash?
  end

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
      cash = self.cashdiv - (self.qty * self.price)  # in portfolio currency
      if cash > 0
        pos = self.position.portfolio.positions.find_by(symbol: self.position.currency_str)
        tr = pos.transactions.create(tr_type: CASH_TR, qty: cash, date: self.date, note: 'Cash from DRIP')
        tr.position.recalculate
      end
    when CASH_TR
      self.price = 1.0
      self.fees = 0.0
    else 
      errors.add(:'Transaction Type', "is invalid")
    end
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
    when CASH_TR
      errors.add(:cashdiv, ': Insufficient amount of shares') if self.qty > self.position.qty
    when DRIP_TR
      cash = self.cashdiv - (self.qty * self.price)  # in portfolio currency
      errors.add(:cashdiv, ': Insufficient amount') if cash < 0
    end
  end

end
