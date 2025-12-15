# frozen_string_literal: true

source 'https://rubygems.org'

# Use tls for github
git_source(:github) { |name| "https://github.com/#{name}.git" }

# --------------------------------
# Shared gems used in Conjur
# --------------------------------

gem 'benchmark'
gem 'command_class'
gem 'concurrent-ruby'
gem 'nokogiri'
gem 'puma', '~> 7'
gem 'rack'
gem 'rails', '~> 8.1'
gem 'rake'

gem 'pg'
gem 'sequel'

gem 'gli'
gem 'ostruct'
gem 'rexml', '~> 3'
gem 'ffi', '>= 1.9.24'
gem 'conjur-rack-heartbeat', '~> 2.2'
gem 'dry-struct'
gem 'dry-types'
gem 'net-ldap', '~> 0.18'

# for AWS rotator
gem 'aws-sdk-iam', '~> 1.86'

# We need this version since any newer introduces breaking change that causes
# issues with safe_yaml: https://github.com/ruby/psych/discussions/571
gem 'psych', '= 3.3.2'

gem 'jwt', '~> 2.7.1'
gem 'anyway_config', '~> 2.6'
gem 'i18n', '~> 1.8.11'

# sigdump allows the server processes to respond to the SIGCONT signal
# and produce a thread dump of the processes for support and debugging.
gem 'sigdump', require: 'sigdump/setup'

group :development, :test do
  gem 'aruba'
  gem 'ci_reporter_rspec'
  gem 'cucumber', '~> 9.2'
  gem 'debase', '~> 0.2.5.beta2'
  gem 'debase-ruby_core_source', '~> 3.3'
  gem 'json_spec', '~> 1.1'
  gem 'net-ssh'

  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'pry-byebug'

  gem 'pry-rails'
  gem 'rails-controller-testing'
  gem 'rspec'
  gem 'rspec-rails'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-commands-cucumber'
  gem 'spring-commands-rspec'

  gem 'vcr'
  gem 'webmock', '>= 3.19.0'

  gem 'cucumber-rails', '~> 3.0', require: false
end

group :development, :test, :test_coverage do
  # We use a post-coverage hook to sleep covered processes until we're ready to
  # collect the coverage reports in CI. Because of this, we don't want bundler
  # to auto-load simplecov. Rather we require it directly when we need it.
  gem 'simplecov', require: false
  gem 'simplecov-cobertura', require: false
end

# --------------------------------
# Other shared gems
# --------------------------------

gem 'conjur-api'
gem 'parallel'
