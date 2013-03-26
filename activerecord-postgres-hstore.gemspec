# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

Gem::Specification.new do |s|
  s.name = "activerecord-postgres-hstore"
  s.version = "0.7.6"

  s.platform    = Gem::Platform::RUBY
  s.license     = "MIT"
  s.authors     = ["Juan Maiz", "Diogo Biazus"]
  s.email       = "juanmaiz@gmail.com"
  s.homepage    = "http://github.com/engageis/activerecord-postgres-hstore"
  s.summary     = "Goodbye serialize, hello hstore"
  s.description = "This gem adds support for the postgres hstore type. It is the _just right_ alternative for storing hashes instead of using seralization or dynamic tables."
  s.required_ruby_version     = ">= 1.8.7"
  s.required_rubygems_version = ">= 1.3.6"

  s.add_dependency "activerecord", ">= 3.1"
  s.add_dependency "rake"
  s.add_dependency 'pg-hstore', '>=1.1.5'
  s.add_development_dependency "bundler"
  s.add_development_dependency "rdoc"
  s.add_development_dependency "rspec", "~> 2.11"

  git_files            = `git ls-files`.split("\n") rescue ''
  s.files              = git_files
  s.test_files         = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables        = []
  s.require_paths      = %w(lib)
end
