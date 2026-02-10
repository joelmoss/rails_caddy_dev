# frozen_string_literal: true

namespace :rails_caddy_dev do
  desc 'Find and return an available TCP port on localhost'
  task available_port: :environment do
    require 'socket'
    puts(Addrinfo.tcp('', 0).bind { |s| s.local_address.ip_port })
  end
end
