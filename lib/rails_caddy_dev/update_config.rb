# frozen_string_literal: true

# Configures Caddy as a local reverse proxy to your Rails server during development.
#
# Uses the Caddy admin API to register a 'route' configuration that proxies requests for
# `<project_name>.localhost` to the locally running Rails server.
#
# This file is intended to be run as part of the `rails server` startup process, and will only
# execute in the development environment, and when the `DEVCADDY` environment variable is set.#
#
# The script checks if a Caddy config for the project already exists by querying the admin API. If
# it does, it sends a PATCH request to update it; if not, it attempts to append a new route to the
# existing config or initialize a new config structure if necessary.
#
# The script accepts the following environment variables:
#   - PROJECT_NAME: Used to derive subdomain hostnames (e.g. "my_project" → my_project.localhost).
#     This is required to ensure unique routing for each project.
#   - PORT: Rails server port (defaults to an available port if not set, or 3000 if port detection
#     fails)
#   - CADDY_HOST: Caddy admin API host (default: localhost)
#   - CADDY_PORT: Caddy admin API port (default: 2019)
#
# If Caddy is not running or the API request fails, the script will print an error message and exit
# with status 1.

require 'net/http'
require 'json'
require 'socket'

return if ENV.fetch('RAILS_ENV', 'development') != 'development' || !ENV.key?('DEVCADDY')

PORT = ENV['PORT'] = ENV.fetch('PORT') do
  Addrinfo.tcp('', 0).bind { |s| s.local_address.ip_port }&.to_s || '3000'
end

CADDY_HOST = ENV.fetch('CADDY_HOST', 'localhost')
CADDY_PORT = ENV.fetch('CADDY_PORT', '2019').to_i
PROJECT_NAME = ENV.fetch('PROJECT_NAME')&.downcase

domains = [
  "#{PROJECT_NAME}.localhost",
  "*.#{PROJECT_NAME}.localhost"
]

# Check if config already exists via Caddy API
uri = URI("http://#{CADDY_HOST}:#{CADDY_PORT}/id/#{PROJECT_NAME}")
config_exists = false
begin
  response = Net::HTTP.get_response(uri)
  config_exists = response.is_a?(Net::HTTPSuccess)
rescue Errno::ECONNREFUSED
  puts "⚠️  Caddy admin API not available at #{CADDY_HOST}:#{CADDY_PORT}. Is caddy running?"
  exit 1
end

config = {
  '@id': PROJECT_NAME,
  handle: [
    {
      handler: 'subroute',
      routes: [
        {
          handle: [
            {
              handler: 'reverse_proxy',
              upstreams: [
                {
                  dial: ":#{PORT}"
                }
              ]
            }
          ]
        }
      ]
    }
  ],
  match: [
    {
      host: domains
    }
  ],
  terminal: true
}

# Caddy admin API
http = Net::HTTP.new(CADDY_HOST, CADDY_PORT)

if config_exists
  # Update existing config via @id endpoint
  request = Net::HTTP::Patch.new("/id/#{PROJECT_NAME}", 'Content-Type' => 'application/json')
  request.body = config.to_json
  action = 'updated'
else
  # Check if routes path exists, if not initialize the full structure
  routes_uri = URI("http://#{CADDY_HOST}:#{CADDY_PORT}/config/apps/http/servers/srv0/routes")
  routes_response = Net::HTTP.get_response(routes_uri)

  if routes_response.is_a?(Net::HTTPSuccess)
    # Routes exist, append to them
    request = Net::HTTP::Post.new(routes_uri.path, 'Content-Type' => 'application/json')
    request.body = config.to_json
  else
    # Initialize full config structure
    request = Net::HTTP::Post.new('/config/', 'Content-Type' => 'application/json')
    request.body = {
      apps: {
        http: {
          servers: {
            srv0: {
              listen: [':443'],
              routes: [config]
            }
          }
        }
      }
    }.to_json
  end
  action = 'created'
end

response = http.request(request)

if response.is_a?(Net::HTTPSuccess)
  puts "=> Caddy config for '#{PROJECT_NAME}:#{PORT}' #{action}"
else
  puts "=! Failed to #{action.chomp('d')} Caddy config: #{response.body}"
  exit 1
end
