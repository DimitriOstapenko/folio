class Quote < ApplicationRecord

  default_scope -> { order(symbol: :asc, exchange: :asc) }
  after_initialize :set_defaults

# symbol is required  
  def set_defaults
    self.symbol = self.symbol.strip.upcase rescue nil
    self.exch ||= '-CT'
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
    quote.fetch
  end

# Fetch fresh quote, fill quote object  
# ARG: self.symbol, self.exch (opt)
def fetch 
  q = IEX_CLIENT.quote(self.symbol + self.exch) rescue nil
  if q
      self.exchange = q.primary_exchange
      self.name = q.company_name
      self.latest_price = q.latest_price
      self.latest_update = q.latest_update_t
      self.volume = q.latest_volume
      self.prev_close = q.previous_close
      self.week52high = q.week_52_high
      self.week52low = q.week_52_low
      self.change = q.change
      self.change_percent = q.change_percent
      self.change_percent_s = q.change_percent_s
      self.ytd_change = q.ytd_change * 100
  else
      self.errors.add(:symbol, "not found")
  end
  self
end

end
