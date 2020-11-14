class Portfolio < ApplicationRecord

  belongs_to :user
  has_many :positions, :dependent => :destroy
  has_many :portfolio_histories, :dependent => :destroy
  validates :name, presence: true, length: { maximum: 50 }
  validates :cash, :currency, presence: true, numericality: true

  default_scope -> { order(name: :asc) }

  belongs_to :user

  before_validation :set_attributes!

  def set_attributes!
    self.currency ||= :CDN
    self.cash ||= 0.0
  end

# Get current CAD exchange rate 
  def fx_rate
    case self.currency
    when USD
      USDCAD
    when EUR
      EURCAD
    else
      1
    end
  end

# What locale show currency in?  
  def locale
    case self.currency
    when USD
      :en
    when EUR
      :fr
    else
      :en
    end
  end
  
  def currency_str
    CURRENCIES.invert[self.currency].to_s rescue nil
  end

  def currency_sym
    CURRENCIES.invert[self.currency]
  end

# Adjusted cost base of all positions in portfolio currency
  def acb
    if self.positions.any?
      self.positions.sum{|pos| pos.acb_base}
    else
      self.cash
    end
  end

# Total market value of all equity positions in portfolio currency
  def curval
    self.positions.sum{|pos| pos.curval_base} + self.cash
  end

  def gain
    if self.positions.any?
      self.curval - self.acb - self.cash
    else 
      self.curval - self.acb
    end
  end

  def gain_pc
    gain = self.gain / self.acb * 100 rescue 0
    gain = 0 if gain.nan?
    return gain
  end

  def total_cad
    self.curval * self.fx_rate
  end

end
