class Position < ApplicationRecord

  belongs_to :portfolio, inverse_of: :positions

  before_validation { symbol.strip!.gsub!(/\s+/,' ') rescue '' }
  before_validation { exch.strip!.gsub!(/\s+/,' ') rescue '' }

end
