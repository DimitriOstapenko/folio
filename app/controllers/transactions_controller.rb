class TransactionsController < ApplicationController

  before_action :logged_in_user
  before_action :init #, only: [:show, :edit, :update, :destroy ]

  helper_method :sort_column, :sort_direction

  def index
    @transactions = @position.transactions
  end

  def new
    @transaction = @position.transactions.new
  end

  def create
    @transaction = @position.transactions.build(transaction_params)
    @transaction.recalculate
    flash[:success] = "New transaction added"
    redirect_to portfolio_position_transactions_path(@portfolio, @position)
  end

   def destroy
     @transaction.destroy && @position.recalculate
     flash[:success] = "Transaction for #{@position.symbol} deleted. "
     redirect_to portfolio_position_transactions_path(@portfolio,@position)
  end

  def edit
  end

  def show
  end

  def update
    @transaction.update_attributes(transaction_params)
    @position.recalculate
    flash[:success] = "Transaction updated. Position recalculated"
    redirect_to portfolio_position_transactions_path(@portfolio,@position)
  end

private
  def init
    @position = Position.find(params[:position_id]) rescue nil
    @portfolio = @position.portfolio
    return if %w(index new create).include?(action_name)   # no transaction for these
    @transaction = Transaction.find(params[:id]) rescue nil
    return if @transaction.present?
    flash[:warning]="**Transaction not found. Action:  #{action_name.inspect}"
    redirect_to portfolio_position_path(@portfolio, @position) 
  end

  def transaction_params
    params.require(:transaction).permit( :qty, :price, :tr_type, :fees, :acb, :gain, :ttl_qty, :cashdiv )
  end

  def sort_column
    Transaction.column_names.include?(params[:sort]) ? params[:sort] : "created_at"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end

end
