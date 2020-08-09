class QuotesController < ApplicationController
  before_action :set_quote, only: [:show, :edit, :update, :destroy]
  before_action :logged_in_user

  def index 
    @quote = Quote.new
    @quotes = Quote.paginate(page: params[:page])
  end

  def new 
    @quote = Quote.new()
  end

  def create
    symbol = params[:quote][:symbol].strip.upcase rescue nil
    exch = params[:quote][:exch] rescue '-CT'
#    flash[:info] = 'Got quote'
    @quote = Quote.find_by(symbol: symbol, exch: exch)
    if @quote
      @quote.fetch && @quote.save if @quote.expired?
      redirect_to @quote
    else
      @quote = Quote.new(symbol: symbol, exch: exch)
      @quote.fetch 
      if @quote.errors.any?
        flash[:info] = @quote.errors.full_messages.to_sentence
        redirect_to quotes_path
      else
        @quote.save
        redirect_to @quote
      end
    end
  end

  def edit
  end

  def update
    @quote.fetch && @quote.save
    if @quote.errors.any?
      flash[:info] = @quote.errors.full_messages.to_sentence
    else
      flash[:info] = "Quote updated"
    end
    redirect_back(fallback_location: quotes_path)
  end

  def show
    @quote.fetch && @quote.save if @quote.expired?
  end

  def destroy
    @quote.destroy
    flash[:success] = "Quote deleted"
    redirect_to quotes_path
  end

private
#  def quote_params
#    params.require(:quote).permit( :symbol, :exchange, :name, :latest_price, :prev_close, :volume, :prev_volume, :latest_update, :week52high, :week52low, :ytd_change, :change, :change_percent, :change_percent_s, :exch) 
#  end  
#
   def set_quote
    @quote = Quote.find(params[:id])
    redirect_to quotes_path unless @quote && @quote.latest_price
   end

end
