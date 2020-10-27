class Transaction < ApplicationRecord
  belongs_to :position
  default_scope -> { order(created_at: :desc) }

  validates :qty, presence: true, numericality: true
  validates :tr_type, presence: true

  before_create :set_attributes!

  def set_attributes!
    if self.tr_type == BUY_TR
      self.qty = self.qty.abs
    elsif self.tr_type == SELL_TR
      self.qty = -self.qty.abs
    end
  end

  def tr_type_str
    TRANSACTION_TYPES.invert[self.tr_type].to_s rescue nil
  end

  def amount
    self.price * self.qty
  end

  def acb_share
    self.acb / self.ttl_qty
  end

  def sell?
    self.qty < 0
  end
  
  def buy?
    self.qty > 0
  end

# Recalculate position and save it along with transaction  
  def recalculate
    self.position.qty += self.qty
    if self.buy?
      self.position.acb += self.amount + self.fees
    else
      self.position.acb += self.qty * self.position.avg_price
      self.gain = -self.amount - self.fees + self.position.avg_price * self.qty
    end
    self.acb = self.position.acb
    self.ttl_qty = self.position.qty
    self.position.save!
  end

end
