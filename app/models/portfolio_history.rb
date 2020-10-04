class PortfolioHistory < ApplicationRecord

  belongs_to :portfolio, inverse_of: :portfolio_histories

  default_scope -> { order(created_at: :desc) }
end
