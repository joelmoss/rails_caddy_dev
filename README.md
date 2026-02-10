# RailsCaddyDev

Automatically configures [Caddy](https://caddyserver.com/) as a local reverse proxy for Rails development. When you start `rails server`, it registers routes via the Caddy admin API so that `<project_name>.localhost` proxies to your locally running Rails server with HTTPS.

## Prerequisites

- [Caddy](https://caddyserver.com/) installed and running locally
- Ruby >= 3.1

## Installation

Add it to your application's Gemfile:

```ruby
gem 'rails_caddy_dev', group: :development
```

Then run:

```bash
bundle install
```

## Setup

In your application's `bin/rails` file,  replace this:

```ruby
require "rails/commands"
```

with this:

```ruby
require "rails_caddy_dev/commands"
```

This will ensure your Caddy configuration is updated each time you start your Rails server in development.

## Usage

Start your Rails server with the `DEVCADDY` and `PROJECT_NAME` environment variables:

```bash
DEVCADDY=1 PROJECT_NAME=myapp rails server
```

This will configure Caddy to proxy `myapp.localhost` to your Rails server, accessible over HTTPS.

### Environment Variables

| Variable | Description | Default |
|---|---|---|
| `DEVCADDY` | Enables Caddy configuration (must be set) | — |
| `PROJECT_NAME` | Used to derive the `.localhost` hostname (required) | — |
| `PORT` | Rails server port to proxy to | `3000` |
| `CADDY_HOST` | Caddy admin API host | `localhost` |
| `CADDY_PORT` | Caddy admin API port | `2019` |

### Dynamic Port Allocation

The gem also provides a CLI command to find an available TCP port, which can be useful if you want to run multiple Rails servers without port conflicts:

```bash
export PORT=$(bundle exec rails rails_caddy_dev:available_port)
```

RailsCaddyDev will then configure Caddy to proxy to the dynamically allocated port, and start your Rails server on that port.

### Subdomains

Subdomains are also supported due to a wildcard Caddy route that will be configured. For example, if you set `PROJECT_NAME=myapp`, then `api.myapp.localhost` will also proxy to your Rails server.

### Usage with Mise

If you're using [Mise](https://github.com/joelmoss/mise), you can integrate RailsCaddyDev by setting the `PORT` environment variable dynamically using the CLI command provided by RailsCaddyDev. Add this to your Mise config (eg. `mise.toml`):

```toml
[env]
PORT = { value = "${env.PORT:-{{exec(command='bundle exec rails rails_caddy_dev:available_port')}}}", tools = true }
```

Now the `PORT` environment variable will be set to an available port each time you start your Mise environment, allowing you to run multiple Rails servers without port conflicts.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/joelmoss/rails_caddy_dev.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
