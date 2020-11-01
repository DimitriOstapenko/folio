class Transaction < ApplicationRecord
  belongs_to :position
  default_scope -> { order(created_at: :desc) }

  validates :qty, presence: true, numericality: true, if: Proc.new { |tr| (tr.tr_type != DRIP_TR)}
  validates :tr_type, presence: true

  before_create :set_attributes!

  def set_attributes!
    self.qty ||= 0.0     # cash div
    self.price ||= 0.0   # cash div
    case self.tr_type
    when BUY_TR
      self.qty = self.qty.abs
    when SELL_TR
      self.qty = -self.qty.abs
    when DRIP_TR
      self.qty = self.qty.abs
      self.position.portfolio.cash += self.cashdiv - (self.qty * self.price)
      self.position.portfolio.save
    else 
      errors.add(:'Transaction Type', "is invalid")
    end
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
    self.acb / self.ttl_qty
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
    self.position.qty += self.qty if self.qty.present?
    case self.tr_type
    when BUY_TR 
      self.position.acb += self.amount + self.fees
    when DRIP_TR
      self.position.acb += self.amount if self.qty.present?
    when SELL_TR
      self.position.acb += self.qty * self.position.avg_price
      self.gain = -self.amount - self.fees + self.position.avg_price * self.qty
    end
    self.acb = self.position.acb
    self.ttl_qty = self.position.qty
    self.position.save!
  end

end
