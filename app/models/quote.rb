class Quote < ApplicationRecord

  validates :symbol, uniqueness: true

  default_scope -> { order(symbol: :asc, exchange: :asc) }
  after_initialize :set_defaults

# symbol is required  
  def set_defaults
    self.symbol = self.symbol.strip.upcase rescue nil
    self.exch ||= '-CT'
    self.change ||= 0
    self.prev_close ||= 0
    self.ytd_change ||= 0
    self.high ||= 0
    self.low ||= 0
    self.week52high ||= 0
    self.week52low ||= 0
    self.pe_ratio ||= 0
  end

# Canadian symbols EOD only; US is real time  
  def expired?
    return true unless self.latest_update.present? # new quote
    return true if self.exch == ''                 # US feed is real time  (&& self.latest_update < 15.minutes.ago  for cached)
    if Time.now.on_weekend?
      return true if self.latest_update < 2.days.ago        
    else 
      return true if self.latest_update < 1.day.ago  
    end
    return false
  end

  def update
    self.fetch && self.save
  end

  def exists?
    self.class.exists?(self.id)
  end

  def ytd_change_str
    self.ytd_change.round(2) rescue 0.00
  end

# Class Methods:
# returns db cached quote if present, last night's quote otherwise 
  def self.get( symbol, exch = '-CT' ) 
    symbol = symbol.strip.upcase rescue nil
    return unless symbol
    quote = Quote.where("symbol=? AND exch=?", symbol, exch).first
    quote = new(symbol: symbol, exch: exch) unless quote.present?
    quote.update if quote.expired?
    return quote
  end

# gold/silver currently excluded from commodities
# Oil: wti: DCOILWTICO brent: DCOILBRENTEU  ngas: DHHNGSP
# wtipriceusd = IEX_CLIENT.get('/data-points/market/DCOILWTICO', token: 'secret')
# syms = IEX_CLIENT.get('ref-data/fx/symbols', token: 'secret')
# syms['pairs'].map {|p| p['symbol']}
# syms = IEX_CLIENT.get('/ref-data/region/CA/symbols/', token: 'secret')
# syms = IEX_CLIENT.get('', token: 'secret')

# Fetch fresh quote, fill quote object  
# ARG: self.symbol, self.exch (opt)
# Only EURCAD and USDCAD fx are supported right now (fetch_fx below supports all)
def fetch 
  return fetch_gold_silver if symbol == 'XAUUSD' || symbol == 'XAGUSD'
  return fetch_usdeur_fx if symbol == 'EUR' || symbol == 'USD'
  return fetch_fx if self.exch == 'fx' 
  return fetch_commodity if self.exch == 'comm'
  q = IEX_CLIENT.quote(self.symbol + self.exch) rescue nil
  if q
      self.exchange = q.primary_exchange
      self.name = q.company_name
      self.latest_price = q.latest_price
      self.latest_update = q.latest_update_t
      self.volume = q.latest_volume || 0
      self.prev_close = q.previous_close
      self.week52high = q.week_52_high
      self.week52low = q.week_52_low
      self.change = q.change
      self.change_percent = q.change_percent
      self.change_percent_s = q.change_percent_s
      self.ytd_change = q.ytd_change * 100  # %
      self.high = q.high
      self.low = q.low
      self.pe_ratio = q.pe_ratio || 0
      self.market_cap = q.market_cap || 0
  else
      self.errors.add(:symbol, "not found")
  end
  self
end

# Currency quotes: symbols 6 characters long
def fetch_fx
  (errors.add(:symbol, "Unrecognized Fx symbol: must be 6 characters"); return self ) unless self.symbol.length == 6  
  self.name = "#{self.symbol[0,3]}/#{self.symbol[3,3]} Exchange Rate" 
  self.latest_price = IEX_CLIENT.get('/fx/latest/', symbols: self.symbol, token: Rails.application.credentials[:iex][:secret_token] )[0]['rate'] rescue 0
  self.latest_update = Time.now
  self
end

# USDCAD | EURCAD
def fetch_usdeur_fx
  sym = "#{self.symbol}CAD"
  self.name = "#{sym} Exchange Rate"
  self.latest_price = IEX_CLIENT.get('/fx/latest/', symbols: sym, token: Rails.application.credentials[:iex][:secret_token] )[0]['rate'] rescue 0
  self
end

def fetch_gold_silver
  self.latest_update = Time.now
  if self.symbol == 'XAUUSD'
    self.name = 'Gold'
    self.latest_price = XAUUSD
  elsif self.symbol == 'XAGUSD'
    self.name = 'Silver' 
    self.latest_price = XAGUSD
  end
  self
end

def fetch_commodity
  self.latest_price = IEX_CLIENT.get("data-points/market/#{self.symbol}", token: Rails.application.credentials[:iex][:secret_token] ) rescue 0
  self.latest_update = Time.now
  self
end

end
