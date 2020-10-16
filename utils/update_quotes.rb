#!/home/oms/.rvm/rubies/ruby-2.6.4/bin/ruby
# 
# Save daily portfolio stats to portfolio_histories table
#
# fx_rate represents exchange rate of portfolio currency to CAD 
#

require_relative '../config/environment'

puts "updating quotes.."

Quote.all.each do |quote|
  next unless quote.expired?
  puts "updating quote for #{quote.symbol}"
  quote.update
end


