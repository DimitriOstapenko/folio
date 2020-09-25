class ApplicationController < ActionController::Base

  include ApplicationHelper
  add_flash_types :info, :warning

  WillPaginate.per_page = 25 

# Confirms a logged-in user.
  def logged_in_user
    redirect_to user_session_path, flash: {warning: "Please log in."} unless current_user
  end
end
