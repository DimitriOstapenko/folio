class Quote < ApplicationRecord

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
    return true if !self.latest_update             # new quote
    return true if self.exch == ''                 # US feed is real time  (&& self.latest_update < 15.minutes.ago  for cached)
    return true if Time.now.on_weekend? && self.latest_update < 2.days.ago        
    return true if self.latest_update < 1.day.ago  # Older than 1 day
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
# returns new quote object, filled 
  def self.get( symbol, exch = '-CT' ) 
    symbol = symbol.strip.upcase rescue nil
    return unless symbol
    quote = new(symbol: symbol, exch: exch)
    if exch.downcase == 'fx'
      quote.fetch_fx
    elsif exch.downcase == 'comm'
      quote.fetch_commodity
    else
      quote.fetch
    end 
  end


# Oil: wti: DCOILWTICO brent: DCOILBRENTEU  ngas: DHHNGSP
# wtipriceusd = IEX_CLIENT.get('/data-points/market/DCOILWTICO', token: 'secret')
# syms = IEX_CLIENT.get('ref-data/fx/symbols', token: 'secret')
# syms['pairs'].map {|p| p['symbol']}
# syms = IEX_CLIENT.get('/ref-data/region/CA/symbols/', token: 'secret')
# syms = IEX_CLIENT.get('', token: 'secret')

# Fetch fresh quote, fill quote object  
# ARG: self.symbol, self.exch (opt)
def fetch 
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

def fetch_fx
  return unless self.symbol.length == 6
  self.name = "#{self.symbol[0,3]}/#{self.symbol[3,3]} Exchange Rate" 
  self.latest_price = IEX_CLIENT.get('/fx/latest/', symbols: self.symbol, token: Rails.application.credentials[:iex][:secret_token] )[0]['rate'] rescue 0
  self.latest_update = Time.now
  self
end

def fetch_commodity
  self.latest_price = IEX_CLIENT.get("data-points/market/#{self.symbol}", token: Rails.application.credentials[:iex][:secret_token] ) rescue 0
  self.latest_update = Time.now
  self
end

end
