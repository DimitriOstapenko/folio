class Position < ApplicationRecord

  belongs_to :portfolio, inverse_of: :positions
  has_many :transactions, dependent: :destroy, autosave: true
  default_scope -> { order(symbol: :asc) }
  attr_accessor :date # to pass to cash transactions

  before_validation :set_attributes!

  validates :symbol, :currency, presence: true
  validates :symbol, uniqueness: {scope: :portfolio_id, message: "is already in portfolio" }
  validates :qty, presence: true, numericality: true
  validates :acb, presence: true, numericality: true #{ greater_than_or_equal_to: 0 }

  after_create :create_first_transaction

  def set_attributes!
    if self.is_cash?
      self.pos_type = CASH_POS
      self.acb = 0  
      self.cash ||= self.qty
      self.symbol = self.currency_str
      self.avg_price = 1
      self.exch = nil
    else 
      self.pos_type = STOCK_POS
    end
    self.symbol.strip!.gsub!(/\s+/,' ') rescue ''
    self.symbol.upcase!
    self.qty ||= 0
    if self.exch == US_EX || self.symbol =='XAUUSD' || self.symbol == 'XAGUSD'
      self.currency = USD 
    elsif self.exch == CA_EX
      self.currency = CAD
    end
    self.avg_price = self.acb / self.qty unless self.is_cash?  rescue 0
  end

  def create_first_transaction
    if self.is_cash?
      self.transactions.create!(tr_type: CASH_TR, cash: self.qty, ttl_cash: self.qty, acb: self.qty, ttl_acb: self.qty, note: self.note)
    else
      self.transactions.create!(tr_type: BUY_TR, qty: self.qty.abs, ttl_qty: self.qty.abs, acb: self.acb, ttl_acb: self.acb, price: self.acb/self.qty, note: self.note)
    end
  end

  def exchange
    EXCHANGES.invert[self.exch].to_s rescue nil
  end

  def locale
    self.currency == EUR ? :fr : :ca 
  end

# Is it cash position?
  def is_cash?
    CURRENCIES.keys.include?(self.symbol.to_sym)  
  end

# Position cash in base currency
  def cash_base
    self.cash * self.fx_rate    
  end  

# Return currency symbol (:CAD, :EUR, :USD) 
  def currency_sym
    CURRENCIES.invert[self.currency]
  end
  
  def currency_str
    CURRENCIES.invert[self.currency].to_s rescue nil
  end

# Position exchange rate relative to portfolio currency 
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
    if self.is_cash?
      return self.cash rescue 0
    else 
      quote = Quote.get(self.symbol, self.exch) 
      self.qty * quote.latest_price rescue 0
    end
  end

# Current market value in portfolio currency (CAD)
  def curval_base
    self.curval * self.fx_rate
  end  

# Adjusted Cost Base in portfolio currency (CAD) 
  def acb_base
    self.acb * self.fx_rate
  end

# Current paper gain in portoflio base currency 
  def ppr_gain
    return 0 if self.is_cash?
    return (self.curval - self.acb) * self.fx_rate
  end

# Paper gain %  
  def ppr_gain_pc
    return 0 if self.acb.abs < 0.01
    sprintf("%.2f", self.ppr_gain / self.acb * 100) rescue 0
  end

# Sum of Dividends for given year 
  def dividends(year = Time.now.year)
    self.transactions.where(tr_type: DIV_TR).sum{|tr| tr.amount } * self.fx_rate
  end

# Recalculate position after change of one of the transactions
  def recalculate(prev = nil)
    self.qty = self.acb = 0; found = false; date =  prev.present? ? prev.date : self.last rescue '1900-01-01'.to_date
    self.transactions.where(tr_type: [BUY_TR,SELL_TR,CASH_TR]).where('date>=?', date).reverse.each do |tr|
      tr.recalculate(prev)
      prev = tr
    end
    if prev
#      logger.debug("###########  prev: #{prev.inspect}")
      self.acb = prev.ttl_acb 
      self.qty = prev.ttl_qty 
      self.cash = prev.ttl_cash
      self.fees = self.transactions.sum(:fees) * self.fx_rate
      self.gain = self.transactions.where(tr_type: SELL_TR).sum(:gain) * self.fx_rate
    end
#      logger.debug("########### pos : #{self.inspect}")
    self.save!
  end

end
