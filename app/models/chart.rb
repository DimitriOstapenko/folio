class Chart < ApplicationRecord

  default_scope -> { order(date: :desc) }

  validates :symbol, :price, presence: true
  validates :date, presence: true, uniqueness: { scope: :symbol }
end
