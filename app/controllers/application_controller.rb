class ApplicationController < ActionController::Base

  include ApplicationHelper
  add_flash_types :info, :warning

  WillPaginate.per_page = 25 
end
