source "http://rubygems.org"

# specify gem dependencies in activerecord-postgres-hstore.gemspec
# except the platform-specific dependencies below
gemspec

group :development, :test do
  gem 'activerecord-jdbcpostgresql-adapter', :platforms => :jruby
  gem 'pg', :platforms => :ruby
end
