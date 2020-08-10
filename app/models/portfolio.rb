class Portfolio < ApplicationRecord

  belongs_to :user
  has_many :positions, :dependent => :destroy
end
