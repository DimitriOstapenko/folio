class Portfolio < ApplicationRecord

  belongs_to :user
  has_many :positions, :dependent => :destroy
  has_many :portfolio_histories, :dependent => :destroy
  validates :name, presence: true, length: { maximum: 50 }
  validates :currency, presence: true, numericality: true
  attr_accessor :cash_in # passing this to new position on portfolio creation
  attr_accessor :year # need this one for taxes page

  default_scope -> { order(name: :asc) }

  belongs_to :user

  before_validation :set_attributes!
  after_create :create_cash_position

  def set_attributes!
    self.currency ||= :CDN
  end

# Create cash position in base currency;   
  def create_cash_position
    self.positions.create!(qty: self.cash_in, currency: self.currency, symbol: self.currency_str, note: 'Initial deposit' ) 
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

# Calculate cash in portfolio currency  
  def cash
    self.positions.where(pos_type: CASH_POS).sum{|pos| pos.cash_base}  # in portfolio currency
  end

# Calculate cash in base currency (CAD) 
  def cash_base 
    self.positions.where(pos_type: CASH_POS).sum{|pos| pos.cash_base} * self.fx_rate  # in CAD
  end

# Adjusted cost base of all positions in portfolio currency
  def acb
    self.positions.sum{|pos| pos.acb_base}
  end

# Total market value of all equity positions in portfolio currency
  def curval
    self.positions.sum{|pos| pos.curval_base} 
  end

  def fees
    self.positions.sum(:fees) 
  end

  def ppr_gain
    self.positions.sum{|pos| pos.ppr_gain} 
  end

  def ppr_gain_pc
    return 0 if self.ppr_gain.zero?
    self.ppr_gain / self.acb * 100 rescue 0
  end

# Cap gain  
  def gain
    self.positions.sum(:gain) 
  end

# Dividends for given year
  def dividends(year)
    self.positions.sum{|pos| pos.dividends(year)}
  end  

# check if position in one or more of the supported currencies is not in portfolio yet  
  def has_available_cash_position?
    avail = CURRENCIES.keys
    taken = self.positions.collect{|p| p.symbol.to_sym}
    (avail & taken).count != avail.count
  end

end
