class Position < ApplicationRecord

  belongs_to :portfolio, inverse_of: :positions
end
