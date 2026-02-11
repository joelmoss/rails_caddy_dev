# frozen_string_literal: true

require 'rails'

module RailsCaddyDev
  class Railtie < ::Rails::Engine
    isolate_namespace RailsCaddyDev
  end
end
