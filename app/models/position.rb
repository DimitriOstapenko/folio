class Position < ApplicationRecord

  belongs_to :portfolio, inverse_of: :positions

  before_validation :set_attributes!
  before_save :set_currency!

  validates :symbol, :currency, presence: true
  validates :qty, presence: true, numericality: true
  validates :acb, presence: true, numericality: { greater_than_or_equal_to: 0 }

  def set_attributes!
    self.symbol.strip!.gsub!(/\s+/,' ').upcase! rescue ''
    self.currency = self.portfolio.currency
  end

  def set_currency!
    if self.symbol == 'EUR'
      self.currency = EUR 
    elsif self.symbol == 'USD' || self.exch == US_EX
      self.currency = USD 
    else
      self.currency = CAD
    end
  end

  def currency_str
    CURRENCIES.invert[self.currency].to_s rescue nil
  end

  def exchange
    EXCHANGES.invert[self.exch].to_s rescue nil
  end

# Return currency symbol (:CAD, :EUR, :USD) 
  def currency_sym
    CURRENCIES.invert[self.currency]
  end

 # Get current exchange rate relative to portfolio currency (CAD stock portfolios only for now)
  def fx_rate
    if self.portfolio.currency_sym == :CAD && self.currency_sym == :USD
      return USDCAD 
    elsif self.portfolio.currency_sym == :CAD && self.currency_sym == :EUR
      return EURCAD 
    else 
      return 1
    end
  end

  def avg_price
    self.acb / self.qty 
  end

# Current market value in position currency 
  def curval
    quote = Quote.get(self.symbol, self.exch) 
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

  def gain
    self.curval - self.acb
  end

  def gain_pc
    sprintf("%.2f", self.gain / self.acb * 100) rescue 0
  end

end
