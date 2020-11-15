class Position < ApplicationRecord

  belongs_to :portfolio, inverse_of: :positions
  has_many :transactions, dependent: :destroy, autosave: true
  default_scope -> { order(symbol: :asc) }

  before_validation :set_attributes!
#  before_save :set_currency_and_avg_price!

  validates :symbol, :currency, presence: true
  validates :symbol, uniqueness: {scope: :portfolio_id, message: "is already in portfolio" }
  validates :qty, presence: true, numericality: true
  validates :acb, presence: true, numericality: true #{ greater_than_or_equal_to: 0 }

  def set_attributes!
    if self.is_cash?
      self.acb = self.qty
      self.symbol = self.currency_str
      self.exch = nil
    end
    self.symbol.strip!.gsub!(/\s+/,' ') rescue ''
    self.symbol.upcase!
    self.qty ||= 0
    if self.exch == US_EX || self.symbol =='XAUUSD' || self.symbol == 'XAGUSD'
      self.currency = USD 
    elsif self.exch == CA_EX
      self.currency = CAD
    end
    self.avg_price = self.acb / self.qty rescue 0
  end

  def exchange
    EXCHANGES.invert[self.exch].to_s rescue nil
  end

# Is it cash position?
  def is_cash?
    CURRENCIES.keys.include?(self.symbol.to_sym)  
  end

# Return currency symbol (:CAD, :EUR, :USD) 
  def currency_sym
    CURRENCIES.invert[self.currency]
  end
  
  def currency_str
    CURRENCIES.invert[self.currency].to_s rescue nil
  end

# Get current exchange rate relative to portfolio currency
  def fx_rate
    if self.portfolio.currency == CAD && self.currency == USD
      return USDCAD 
    elsif self.portfolio.currency == CAD && self.currency == EUR
      return EURCAD 
    elsif self.portfolio.currency == EUR && self.currency == CAD
      return 1/EURCAD
    elsif self.portfolio.currency == EUR && self.currency == USD
      return 1/EURUSD
    elsif self.portfolio.currency == USD && self.currency == CAD
      return 1/USDCAD
    elsif self.portfolio.currency == USD && self.currency == EUR
      return EURUSD
    else
      return 1
    end
  end

# Current market value in position currency 
  def curval
    quote = Quote.get(self.symbol, self.exch) 
    quote.latest_price = 1 if self.is_cash?  
    self.qty * quote.latest_price rescue 0
  end

# Current market value in portfolio currency (CAD)
  def curval_base
    self.curval * self.fx_rate
  end  

# Adjusted Cost Base in portfolio currency (CAD) 
  def acb_base
    self.acb * self.fx_rate
  end

# Current gain  
  def gain
    self.curval - self.acb
  end

  def gain_pc
    return 0 if self.acb.abs < 0.01
    sprintf("%.2f", self.gain / self.acb * 100) rescue 0
  end

# Locked in Cap Gain
  def cap_gain
    self.transactions.sum{ |tr| tr.gain * self.fx_rate } 
  end  

# Recalculate position after change of one of the transactions
  def recalculate
    self.qty = self.acb = 0
    self.transactions.reverse.each do |tr|
      tr.recalculate
    end
  end

end
