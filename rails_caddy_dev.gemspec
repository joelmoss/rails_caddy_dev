# frozen_string_literal: true

require_relative 'lib/rails_caddy_dev/version'

Gem::Specification.new do |spec|
  spec.name = 'rails_caddy_dev'
  spec.version = RailsCaddyDev::VERSION
  spec.authors = ['Joel Moss']
  spec.email = ['joel@developwithstyle.com']

  spec.summary = 'Automatic Caddy config for Rails development.'
  spec.homepage = 'https://github.com/joelmoss/rails_caddy_dev'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.1.0'

  spec.metadata['rubygems_mfa_required'] = 'true'
  spec.executables = ['rails_caddy_dev']

  spec.require_paths = ['lib']
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir['lib/**/*', 'bin/rails_caddy_dev', 'MIT-LICENSE', 'README.md']
  end

  spec.add_dependency 'rails', ['>= 7.1.0', '< 9.0']
end
