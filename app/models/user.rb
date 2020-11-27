class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :validatable, :trackable, :timeoutable

  has_many :portfolios, dependent: :destroy

# Number of shares for each position in current user's portfolios
def get_symbol_qty(symbol)
  qty = Position.joins(:portfolio).where(symbol: symbol).where('portfolios.user_id': self.id).sum(:qty).to_int
  qty = nil if qty.zero?
  return qty
end

end
