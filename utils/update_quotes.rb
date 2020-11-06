#!/home/oms/.rvm/rubies/ruby-2.6.4/bin/ruby
# 
# Update active quotes; Add historical chart data 
#

require_relative '../config/environment'
puts "updating quotes.."

Quote.all.each do |quote|
  next unless quote.expired?
  puts "updating quote for #{quote.symbol}"
  quote.update
  quote.update_chart
end


