class PositionsController < ApplicationController
  before_action :logged_in_user
  before_action :init, only: [:show, :edit, :update, :destroy  ]

  helper_method :sort_column, :sort_direction

  def index
    @portfolio = Portfolio.find(params[:portfolio_id])
    @positions = @portfolio.positions.paginate(page: params[:page])
  end

  def all_positions
    @positions = Position.joins(:portfolio).where('portfolios.user_id': current_user.id).paginate(page: params[:page])
  end

  def new
    @portfolio = Portfolio.find(params[:portfolio_id])
    @position = @portfolio.positions.new
    @transaction = @position.transactions.new
  end

# Create new position or new cash transaction if already present
  def create
    @portfolio = Portfolio.find(params[:portfolio_id])
    newpos = @portfolio.positions.build(position_params)
    @position = @portfolio.positions.find_by(symbol: newpos.symbol) 
    if @position.present?
      if @position.is_cash?
        @position.transactions.create!(tr_type: CASH_TR, cash: newpos.qty, acb: newpos.qty, note: newpos.note, cashdep: true)
        @position.recalculate
        flash[:success] = "Cash added"
      else   
        flash[:danger] = "Position #{symbol} is already in portfolio. Try adding transaction"
      end
    else 
      if newpos.save
        @position = newpos 
        flash[:success] = "New position created"
      else
        render 'new'
        return
      end
    end
    redirect_to portfolio_holdings_path(@portfolio)
  end

  def destroy
    @position.destroy
    flash[:success] = "Position #{@position.symbol} deleted. "
    redirect_to portfolio_holdings_path(@portfolio)
  end

  def edit
  end

  def show
    @transactions = @position.transactions
  end

  def update
    if @position.update(position_params)
      flash[:success] = "Position updated"
      redirect_to portfolio_holdings_path(@portfolio)
    else
      render 'edit'
    end
  end

 private

  def init
    @portfolio = Portfolio.find(params[:portfolio_id]) rescue nil
    @position = Position.find(params[:id]) rescue nil
    (flash[:warning]="Position not found"; redirect_to portfolio_holdings_path) unless @position
  end

  def position_params
    params.require(:position).permit( :symbol, :exch, :qty, :acb, :currency, :avg_price, :cash, :fees, :gain, :note, :pos_type )
  end

  def sort_column
    Position.column_names.include?(params[:sort]) ? params[:sort] : "symbol"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end


end
