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

# Calculate cash in base currency
  def cash
    self.positions.sum{|pos| pos.is_cash? ? pos.curval_base : 0}
  end

# Adjusted cost base of all positions in portfolio currency
  def acb
    self.positions.sum{|pos| pos.acb_base}
  end

# Total market value of all equity positions in portfolio currency
  def curval
    self.positions.sum{|pos| pos.curval_base} 
  end

  def gain
      self.curval - self.acb
  end

  def gain_pc
    self.gain / self.acb * 100 rescue 0
  end

  def total_cad
    self.curval * self.fx_rate
  end

# check if position in one or more of the supported currencies is not in portfolio yet  
  def has_available_cash_position?
    avail = CURRENCIES.keys
    taken = self.positions.collect{|p| p.symbol.to_sym}
    (avail & taken).count != avail.count
  end

end
