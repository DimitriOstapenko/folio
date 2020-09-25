class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :validatable, :trackable, :timeoutable

  has_many :portfolios, dependent: :destroy

end
