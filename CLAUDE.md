# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

`rails_caddy_dev` is a Ruby gem that automatically configures [Caddy](https://caddyserver.com/) as a local reverse proxy for Rails development. It uses the Caddy admin API to register routes that proxy `<project_name>.localhost` (and subdomains) to a locally running Rails server.

## Commands

- **Setup:** `bin/setup`
- **Tests:** `bundle exec rake test` (Minitest)
- **Single test:** `bundle exec ruby -Ilib:test test/test_rails_caddy_dev.rb --name test_name`
- **Lint:** `bundle exec rubocop`
- **Lint with autofix:** `bundle exec rubocop -A`
- **Default task (test + lint):** `bundle exec rake`
- **Interactive console:** `bin/console`
- **Build gem:** `bundle exec rake build`

## Architecture

- `lib/rails_caddy_dev.rb` — Entry point. Uses Zeitwerk for autoloading and requires Thor.
- `lib/rails_caddy_dev/commands.rb` — Thor-based CLI (`bin/rails_caddy_dev`). Defines subcommands like `available_port`.
- `lib/rails_caddy_dev/update_config.rb` — Core logic. Meant to be required from a Rails app's `bin/rails` during `rails server` startup. Only runs when `RAILS_ENV=development` and `DEVCADDY` env var is set. Talks to the Caddy admin API (default `localhost:2019`) via `net/http` to create/update reverse proxy routes.
- `sig/rails_caddy_dev.rbs` — RBS type signatures.

## Code Style (RuboCop)

- Max line length: 100
- Indentation: `indented_internal_methods`
- **Disabled syntax:** `unless`, `and`/`or`/`not`, numbered parameters (`_1`, `_2`)
- Use `if !condition` instead of `unless condition`
- Metrics cops are disabled
- Required Ruby version: >= 3.1
