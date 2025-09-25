#!/usr/bin/env bash
# exit on error
set -o errexit

# Install dependencies
bundle install
yarn install

# Precompile assets
bundle exec rails assets:precompile

# Run database migrations
bundle exec rails db:migrate