class Transaction < ApplicationRecord
  belongs_to :position

  validates :qty, presence: true, numericality: true
end
