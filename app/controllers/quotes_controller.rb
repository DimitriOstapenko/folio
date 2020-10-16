class QuotesController < ApplicationController
  before_action :set_quote, only: [:show, :edit, :update, :destroy]
  before_action :logged_in_user

  def index 
    @quotes = Quote.paginate(page: params[:page])
  end

  def new 
    @quote = Quote.new()
  end

  def create
    symbol = params[:quote][:symbol].strip.upcase rescue nil
    exch = params[:quote][:exch] || '-CT'
    exch = 'comm' if symbol.match?('XA(U|G)USD')
#    flash[:info] = "About to get quote from db for:  #{symbol.inspect} exch:  #{exch.inspect}"
    @quote = Quote.find_by(symbol: symbol, exch: exch)
    if @quote
#    flash[:info] = "Got quote from db:  #{@quote.inspect} #{symbol} #{exch}"
      flash[:info] = "Got expired - updating.. (updated #{@quote.updated_at})" if @quote.expired?
     @quote.update if @quote.expired?
      redirect_to @quote
    else
      @quote = Quote.new(symbol: symbol, exch: exch)
      @quote.fetch 
      if @quote.errors.any?
        flash[:info] = @quote.errors.full_messages.to_sentence
        redirect_to quotes_path
      else
        @quote.save
#        flash[:info] = "Fetched & saved new quote: #{@quote.inspect}"
        redirect_to @quote
      end
    end
  end

  def edit
  end

  def update
    @quote.update
    if @quote.errors.any?
      flash[:info] = @quote.errors.full_messages.to_sentence
    else
      flash[:info] = "Quote updated"
    end
    redirect_back(fallback_location: quotes_path)
  end

  def show
    @quote.update if @quote.expired?
#    flash[:info] = @quote.inspect
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
     @quote = Quote.find(params[:id]) rescue nil
    
    redirect_to quotes_path, alert: 'Quote does not exist'  unless @quote #&& @quote.latest_price
   end

end
