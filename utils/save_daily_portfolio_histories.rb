#!/home/oms/.rvm/rubies/ruby-2.6.4/bin/ruby
# 
# Save daily portfolio stats to portfolio_histories table
#
# fx_rate represents exchange rate of portfolio currency to CAD 
#

require_relative '../config/environment'

latest_date = PortfolioHistory.first.created_at.to_date
abort "Portfolio stats already imported for this date - aborted"  if latest_date && latest_date == Date.today 
Portfolio.all.each do |p|
  p.portfolio_histories.create(user_id: p.user_id, acb: p.acb, cash: p.cash, curval: p.curval, fx_rate: p.fx_rate)
end


