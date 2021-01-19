require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Folio
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1
    config.autoload_paths << "#{Rails.root}/lib"

    I18n.enforce_available_locales = false
    I18n.config.available_locales = [:en]
    config.i18n.default_locale = :en

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"

    config.time_zone = "America/New_York"
    config.active_record.default_timezone = :local
    config.active_record.time_zone_aware_attributes = false

    # config.eager_load_paths << Rails.root.join("extras")

  end
end
