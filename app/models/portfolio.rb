class Portfolio < ApplicationRecord

  belongs_to :user
  has_many :positions, :dependent => :destroy
  validates :name, presence: true, length: { maximum: 50 }
  validates :cash_in, presence: true, numericality: { greater_than_or_equal_to: 0 }

  belongs_to :user

  before_validation :set_attributes!

  def set_attributes!
    currency = :CDN
  end

# Adjusted cost base across all positions  
  def acb
    acb = 0
    self.positions.each do |pos|
      acb += pos.avg_price * pos.qty
    end
    return acb
  end

  def curval
    ttl = 0
    self.positions.each do |pos|
      quote = Quote.get(pos.symbol)
      ttl += pos.qty * quote.latest_price
    end
    return ttl
  end

  def gain
    self.curval - self.acb
  end

  def gain_pc
    sprintf("%.2f", self.gain / self.acb * 100) rescue 0
  end

end
