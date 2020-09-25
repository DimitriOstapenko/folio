module ApplicationHelper

  include ActionView::Helpers::NumberHelper

# Guess device type
# /mobile|android|iphone|blackberry|iemobile|kindle/
    def device_type
      ua  = request.user_agent.downcase rescue 'unknown'
      if ua.match(/macintosh|windows/)
         'desktop'
      else
         'mobile'
      end
    end

def device_is_desktop?
  device_type == 'desktop'
end

def mobile_device?
  device_type == 'mobile'
end

def sortable(column, title = nil)
      title ||= ActiveSupport::Inflector.titleize(column)
      direction = (sort_direction == "asc") ? "desc" : "asc"
      link_to title, { direction: direction, sort: column, findstr: params[:findstr] }, class: "hdr-link"
end

def num_to_phone( phone, area_code = true )
  number_to_phone(phone, area_code: :true) rescue ''
end

def to_currency (number, locale: :ca)
  number_to_currency(number, locale: locale)
end


end
