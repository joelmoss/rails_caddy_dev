# frozen_string_literal: true

# This file is responsible for loading the Caddy configuration update logic when the Rails server is
# started in development mode with the DEVCADDY environment variable set. It should be required from
# the application's 'bin/rails' file, as a replacement for the default 'require "rails/commands"'
# line, making it look something like this:
#
#   #!/usr/bin/env ruby
#
#   APP_PATH = File.expand_path("../config/application", __dir__)
#   require_relative "../config/boot"
#
#   # require "rails/commands" # <-- This line should be removed, and replaced with the line below.
#   require "rails_caddy_dev/commands" # <-- This line is added to load the Caddy config logic
#
if ENV.fetch('RAILS_ENV', 'development') == 'development' &&
   ENV.key?('DEVCADDY') &&
   %w[s server].include?(ARGV.first)
  require 'rails_caddy_dev/update_config'
end

require 'rails/commands'
