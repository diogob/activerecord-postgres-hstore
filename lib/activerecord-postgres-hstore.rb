#raise ActiveRecord::ConnectionAdapters::Column.inspect
require 'rails'
require 'rails/generators'
require 'rails/generators/migration'
class Railtie < Rails::Railtie
  initializer 'activerecord-postgres-hstore' do
    ActiveSupport.on_load :active_record do
      require "activerecord-postgres-hstore/activerecord"
    end
  end
  #rake_tasks do
  #  load "lib/tasks/hstore.rake"
  #end
  class HstoreGenerator < Rails::Generators::Base
    include Rails::Generators::Migration

    def self.source_root
      @source_root ||= File.join(File.dirname(__FILE__), 'templates')
    end

    def self.next_migration_number(dirname)
      if ActiveRecord::Base.timestamped_migrations
        Time.now.utc.strftime("%Y%m%d%H%M%S")
      else
        "%.3d" % (current_migration_number(dirname) + 1)
      end
    end

    def create_migration_file
      migration_template 'setup_hstore.rb', 'db/migrate/setup_hstore.rb'
    end

  end
end





require "activerecord-postgres-hstore/hstore"
require "activerecord-postgres-hstore/string"
require "activerecord-postgres-hstore/hash"
