class PortfolioHistory < ApplicationRecord

  belongs_to :portfolio, inverse_of: :portfolio_histories
end
