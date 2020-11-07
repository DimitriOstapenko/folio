#!/home/oms/.rvm/rubies/ruby-2.6.4/bin/ruby
# 
# Update active quotes; Add historical chart data 
#

require_relative '../config/environment'
puts "updating quotes.."

Quote.all.each do |quote|
  puts "#{quote.symbol}: updating chart.."
  quote.update_chart
  next unless quote.expired?
  puts "updating quote"
  quote.update
end


