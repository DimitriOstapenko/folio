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

def num_to_phone( phone, area_code = true )
  number_to_phone(phone, area_code: :true) rescue ''
end

def to_currency (number, locale: :ca)
  number_to_currency(number, locale: locale)
end


end
