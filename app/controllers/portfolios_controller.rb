class PortfoliosController < ApplicationController

  before_action :logged_in_user
  before_action :init, only: [:show, :edit, :update, :destroy ]
  
  helper_method :sort_column, :sort_direction

  def index
    @portfolios = current_user.portfolios
    @total_cash = @portfolios.sum{|p| p.cash}
    @total_acb = @portfolios.sum{|p| p.acb} 
    @total_curval = @portfolios.sum{|p| p.curval} 
    @total_gain = @portfolios.sum{|p| p.gain} 
    @total_gain_pc = @portfolios.sum{|p| p.gain_pc} / @portfolios.size
    @total_cad_value = @portfolios.sum{|p| p.curval*p.fx_rate}
  end

  def new
    @portfolio = Portfolio.new
  end

  def create
    @user = current_user
    @portfolio = @user.portfolios.build(portfolio_params)
    if @portfolio.save
       flash[:success] = "New portfolio created"
       redirect_to portfolios_path
    else
       render 'new'
    end
  end

  def edit
  end

  def show
  end

  def update
    if @portfolio.update_attributes(portfolio_params)
      flash[:success] = "Portfolio updated"
      redirect_to portfolios_path
    else
      render 'edit'
    end
  end

  def destroy
    flash[:success] = "Portfolio #{@portfolio.name} deleted. "
    @portfolio.destroy
    redirect_to portfolios_path
  end

  private

  def init
    @portfolio = Portfolio.find(params[:id]) rescue nil
    (flash[:warning]="Portfolio not found"; redirect_to portfolios_path) unless @portfolio
  end

  def portfolio_params
    params.require(:portfolio).permit( :name, :currency, :cash )
  end

  def sort_column
    Portfolio.column_names.include?(params[:sort]) ? params[:sort] : "name"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end

end
