class Quote < ApplicationRecord

#  validates :symbol, uniqueness: true
  validates :symbol, uniqueness: {scope: :exch, message: "is already in quotes table" }

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
    self.exch = 'comm' if self.symbol == 'XAUUSD' || self.symbol == 'XAGUSD'
  end

# Canadian symbols EOD only; US is real time  
  def expired?
    return false if self.is_cash?
    return true unless self.latest_update.present? # new quote
    return true if self.exch == '' && Date.current.on_weekday?   # US feed is real time  (&& self.latest_update < 15.minutes.ago  for cached)
    if Date.today.sunday? || Date.current.monday?
      return true if self.latest_update < 2.days.ago        
    else 
      return true if self.latest_update < 1.day.ago  
    end
    return false
  end

  def update
    self.fetch && self.save
  end

# If oldest point is this year, go back 1 year and get chart data up to today. Otherwise, just save most recent data point
  def update_chart
    oldest_point_date = Chart.where(symbol: self.symbol).where(exch: self.exch).last.date rescue Date.today

    if oldest_point_date > Date.today.beginning_of_year   # get chart data from 1yr back
      hist_chart = IEX_CLIENT.chart(self.symbol + self.exch, '1y') rescue []
      hist_chart.each do |ch|
        point = Chart.new(symbol:self.symbol, exch:self.exch, date:ch.date, price: ch.close, volume:ch.volume) rescue nil
        point.save if point && point.valid? 
      end
    else
#     just add most recent data point      
      latest = IEX_CLIENT.chart(self.symbol.gsub('-','.') + self.exch, '5d').last rescue nil
      (puts "could not get IEX chart for #{self.symbol}"; return) unless latest
      Chart.create(symbol:self.symbol, exch:self.exch, date:latest.date, price: latest.close, volume: latest.volume) if latest
      self.update_attribute(:volume, latest.volume) 
    end
  end  

#  def exists?
#    self.class.exists?(self.id)
#  end

  def ytd_change_str
    self.ytd_change.round(2) rescue 0.00
  end

# Class Method:
# returns db cached quote if present, last night's quote otherwise 
  def self.get( symbol, exch = '-CT' ) 
    return unless symbol
    symbol = symbol.strip.upcase rescue nil
    quote = Quote.find_by(symbol: symbol, exch: exch)
    if quote.present? 
      quote.update if quote.expired?  # US live quotes only! Cdn are updated in utils/update_quotes.rb 
    else
      quote = Quote.new(symbol: symbol, exch: exch)
      quote.update unless quote.is_cash?
    end
    return quote
  end

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
  return fetch_commodity if self.exch == 'comm'
  return fetch_fx if self.exch == 'fx' 
  q = IEX_CLIENT.quote(self.symbol + self.exch) rescue nil
  if q
      self.exchange = q.primary_exchange || ''
      self.name = q.company_name || ''
      self.latest_price = q.latest_price || 0.0
      self.latest_update = q.latest_update_t || nil
      self.volume = q.latest_volume if q.latest_volume > 0
      self.prev_close = q.previous_close || 0.0
      self.week52high = q.week_52_high || 0.0
      self.week52low = q.week_52_low || 0.0
      self.change = q.change || 0.0
      self.change_percent = q.change_percent
      self.change_percent_s = q.change_percent_s
      self.ytd_change = q.ytd_change * 100  # %
      self.high = q.high || 0.0
      self.low = q.low || 0.0
      self.pe_ratio = q.pe_ratio || 0.0
      self.market_cap = q.market_cap || 0.0
  else
      self.errors.add(:symbol, "not found")
  end
  self
end

# Currency quotes: symbols 6 characters long
def fetch_fx
  (errors.add(:'Unrecognized Fx symbol', "- must be 6 characters"); return self ) unless self.symbol.length == 6  
  self.latest_price = IEX_CLIENT.get('/fx/latest/', symbols: self.symbol, token: Rails.application.credentials[:iex][:secret_token] )[0]['rate'] rescue 0
  (errors.add(:'Fx symbol', "not found"); return self ) unless self.latest_price > 0  
  self.name = "#{self.symbol[0,3]}/#{self.symbol[3,3]} Exchange Rate" 
  self.latest_update = Time.current
  self
end

# Get commodity prices including gold and silver
def fetch_commodity
  if self.symbol == 'XAUUSD'
    self.name = 'Gold'
    self.latest_price = XAUUSD
  elsif self.symbol == 'XAGUSD'
    self.name = 'Silver'
    self.latest_price = XAGUSD
  else
    self.latest_price = IEX_CLIENT.get("data-points/market/#{self.symbol}", token: Rails.application.credentials[:iex][:secret_token] ) rescue 0
    (errors.add(:'Commodity Symbol', "not found"); return self ) unless self.latest_price > 0  
  end
  self.latest_update = Time.current
  self
end

# Read yahoo rss news
def news
  require 'rss'
  require 'open-uri'
  exch = ''; news = []
  exch = '.TO' if self.exch == '-CT'
  uri = 'http://finance.yahoo.com/rss/headline?s='+ self.symbol + exch
  puts uri
  rss = open(uri)
  feed = RSS::Parser.parse(rss)
  feed.items.each do |item|
    news.push({ title: item.title, date: item.pubDate, link: item.link, description: item.description })
  end
  return news
end

def is_cash?
  CURRENCIES.keys.include?(self.symbol.to_sym)
end

end
