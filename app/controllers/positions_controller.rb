class PositionsController < ApplicationController
  before_action :logged_in_user
  before_action :init, only: [:show, :edit, :update, :destroy ]

  helper_method :sort_column, :sort_direction

  def index
    @portfolio = Portfolio.find(params[:portfolio_id])
    @positions = @portfolio.positions
  end

  def create
  end

  def destroy
  end

  def edit
  end

  def show
  end

  def update
  end

 private

  def init
    @portfolio = Portfolio.find(params[:portfolio_id]) rescue nil
    @position = Position.find(params[:id]) rescue nil
    (flash[:warning]="Position not found"; redirect_to portfolio_positions_path) unless @position
  end

  def sort_column
    Position.column_names.include?(params[:sort]) ? params[:sort] : "symbol"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end


end
