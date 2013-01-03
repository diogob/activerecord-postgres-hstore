require 'rails'
require 'rails/generators'
require 'rails/generators/migration'

# = Hstore Railtie
#
# Creates a new railtie for 2 reasons:
#
# * Initialize ActiveRecord properly
# * Add hstore:setup generator
class Hstore < Rails::Railtie

  initializer 'activerecord-postgres-hstore' do
    ActiveSupport.on_load :active_record do
      require "activerecord-postgres-hstore/activerecord"
    end
  end

  # Creates the hstore:setup generator. This generator creates a migration that
  # adds hstore support for your database. If fact, it's just the sql from the
  # contrib inside a migration. But it' s handy, isn't it?
  #
  # To use your generator, simply run it in your project:
  #
  #   rails g hstore:setup
  class Setup < Rails::Generators::Base
    include Rails::Generators::Migration

    def self.source_root
      @source_root ||= File.join(File.dirname(__FILE__), '../templates')
    end

    def self.next_migration_number(dirname)
      if ActiveRecord::Base.timestamped_migrations
        Time.now.utc.strftime("%Y%m%d%H%M%S")
      else
        "%.3d" % (current_migration_number(dirname) + 1)
      end
    end

    def create_migration_file
      pgversion = ActiveRecord::Base.connection.send(:postgresql_version)
      if pgversion < 90100
        migration_template 'setup_hstore.rb', 'db/migrate/setup_hstore.rb'
      else
        migration_template 'setup_hstore91.rb', 'db/migrate/setup_hstore.rb'
      end
    end

  end
end

