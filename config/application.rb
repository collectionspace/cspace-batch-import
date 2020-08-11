require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module CspaceBatchImport
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    config.superuser_email = ENV.fetch(
      'CSPACE_BATCH_IMPORT_SUPERUSER_EMAIL', 'superuser@collectionspace.org'
    )
    config.superuser_password = ENV.fetch(
      'CSPACE_BATCH_IMPORT_SUPERUSER_PASSWORD', 'password'
    )
  end
end
