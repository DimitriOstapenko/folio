class TaxesController < ApplicationController

  before_action :logged_in_user

  def index
    @portfolios = current_user.portfolios.where(taxable: true)

    flash[:info] = current_user.email
  end

  def show
  end
end
