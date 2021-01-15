class PortfoliosController < ApplicationController

  before_action :logged_in_user
  before_action :init #, only: [:show, :edit, :update, :destroy, :add_cash, :dividends, :cash, :deposits, :holdings, :transactions, :taxes, :trades ]
  
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
      @total_cash = @portfolios.sum{|p| p.cash * p.fx_rate } * @fx
      @total_acb = @portfolios.sum{|p| p.acb * p.fx_rate } * @fx
      @total_curval = @portfolios.sum{|p| p.curval * p.fx_rate } * @fx 

#      flash[:success] = "bFx: #{@fx}"
    end
    @total_rgain = @portfolios.sum{|p| p.gain * p.fx_rate } * @fx
    @total_ppr_gain = @portfolios.sum{|p| p.ppr_gain }
    @total_ppr_gain_pc = @total_ppr_gain / @total_curval * 100 rescue 0

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
    if @portfolio.update(portfolio_params)
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

  def dividends
    @dividends = Transaction.joins(:position).where('positions.portfolio_id': @portfolio.id).where(tr_type: DIV_TR)
    @dividends = @dividends.paginate(page: params[:page])

#    flash[:warning] = "Portfolio: #{@portfolio.inspect}"
  end
  
  def cash
    @cash = Transaction.joins(:position).where('positions.portfolio_id': @portfolio.id).where(tr_type: CASH_TR)
    @cash = @cash.paginate(page: params[:page])
  end

  def deposits
    @deposits = Transaction.joins(:position).where('positions.portfolio_id': @portfolio.id).where(tr_type: CASH_TR).where(cashdep:true)
    @deposits = @deposits.paginate(page: params[:page])
  end
  
  def holdings
    @positions = @positions.where(pos_type: STOCK_POS).paginate(page: params[:page])
  end
  
# all transactions across all portoflios  @transactions = Transaction.joins(:position).merge(Position.joins(:portfolio)).where('portfolios.user_id': current_user.id)
  def trades
    @transactions = Transaction.joins(:position).merge(Position.joins(:portfolio)).where('positions.portfolio.id': @portfolio.id).where('positions.pos_type': STOCK_POS)
    @transactions = @transactions.paginate(page: params[:page], per_page: 30)
  end

  def taxes
#    @taxes = Transaction.joins(:position).merge(Position.joins(:portfolio)).where('positions.portfolio.id': @portfolio.id).where('portfolios.taxable': true)
  end

  private

  def init
    id = params[:portfolio_id] || params[:id]
    return unless id
    @portfolio = Portfolio.find(id)

    if @portfolio.present?
      @positions = @portfolio.positions
    else
      flash[:warning] = "Portfolio ** #{params.inspect} not found"
    end
  end

  def portfolio_params
    params.require(:portfolio).permit( :name, :currency, :cashonly, :taxable, :cash_in )
  end

  def sort_column
    Portfolio.column_names.include?(params[:sort]) ? params[:sort] : "name"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end

end
