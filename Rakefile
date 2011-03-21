require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "activerecord-postgres-hstore"
    gem.summary = %Q{Goodbye serialize, hello hstore}
    gem.description = %Q{This gem adds support for the postgres hstore type. It is the _just right_ alternative for storing hashes instead of using seralization or dynamic tables.}
    gem.email = "juanmaiz@gmail.com"
    gem.homepage = "http://github.com/softa/activerecord-postgres-hstore"
    gem.authors = ["Juan Maiz"]
    gem.add_development_dependency "rspec", ">= 2.0.0"
    gem.files = FileList['.document', '.gitignore', 'LICENSE', 'README.rdoc', 'Rakefile', 'VERSION', 'spec/**/*_spec.rb', 'lib/**/*.rb'].to_a
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end


require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = ["-r ./spec/spec_helper.rb"]
  t.pattern = 'spec/**/*_spec.rb'
end

# not sure about rcov task...
# RSpec::Core::RakeTask.new("rcov") do |t|
#   t.rcov = true
# end


task :spec => :check_dependencies
task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "activerecord-postgres-hstore #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
