# frozen_string_literal: true

require 'rails'

module RailsCaddyDev
  class Railtie < ::Rails::Engine
    isolate_namespace RailsCaddyDev

    rake_tasks do
      load 'rails_caddy_dev/railties/available_port.rake'
    end
  end
end
