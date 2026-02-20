#!/usr/bin/env bash
# Build script for Render.com native (non-Docker) deploys
set -o errexit

bundle install
bundle exec rails assets:precompile
bundle exec rails db:prepare
