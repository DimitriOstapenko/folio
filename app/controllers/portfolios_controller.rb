class PortfoliosController < ApplicationController

  before_action :logged_in_user
  before_action :init, only: [:show, :edit, :update, :destroy, :add_cash ]
  
  helper_method :sort_column, :sort_direction

  def index
    @currency =  params[:portfolio][:currency]  rescue nil
    @base_currency = params[:portfolio][:base_currency] rescue nil
    @portfolios = current_user.portfolios 
    @portfolios = @portfolios.where(currency: @currency) if @currency.present?

    if @currency.present?
      @fx = 1 
      @fx = eval "#{CURRENCIES.invert[@currency.to_i]}#{CURRENCIES.invert[@base_currency.to_i]}"  if @currency != @base_currency
      @total_cash = @portfolios.sum{ |p| p.cash } * @fx
      @total_acb = @portfolios.sum{ |p| p.acb } * @fx
      @total_curval = @portfolios.sum{ |p| p.curval } * @fx 
#      flash[:success] = "Fx: #{@fx}"
    else
      @fx = 1
      @fx = eval "CAD#{CURRENCIES.invert[@base_currency.to_i]}" if @base_currency.to_i != CAD
      @total_cash = @portfolios.sum{ |p| p.cash * p.fx_rate } * @fx
      @total_acb = @portfolios.sum{ |p| p.acb * p.fx_rate } * @fx
      @total_curval = @portfolios.sum{ |p| p.curval * p.fx_rate } * @fx 
#      flash[:success] = "bFx: #{@fx}"
    end
    @total_gain = @total_curval - @total_acb
    @total_gain_pc = @total_gain / @total_curval * 100 rescue 0
    @total_base_value = @total_curval 

#    flash[:success] = "Showing portfolios in #{@portfolios[0].currency_str}" if @currency.present?
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

# Add cash transaction   
  def add_cash
    @position = @portfolio.positions.find_by(symbol: 'CASH') || @portfolio.positions.new(symbol: 'CASH')
    @transaction = @position.transactions.new(tr_type: CASH_TR, price: 1.0, fees: 0.0 )

#     cash = params[:qty]
#     @portfolio.update_attribute(cash: @portfolio.cash + cash)
#    @portfolio.position.create(symbol: 'CASH', exch: '', currency: @portfolio.currency, qty: params[:qty])
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
    params.require(:portfolio).permit( :name, :currency, :cashonly )
  end

  def sort_column
    Portfolio.column_names.include?(params[:sort]) ? params[:sort] : "name"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end

end
