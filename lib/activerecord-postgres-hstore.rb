#raise ActiveRecord::ConnectionAdapters::Column.inspect
require 'rails'
class Railtie < Rails::Railtie
  initializer 'paperclip.extends' do
    ActiveSupport.on_load :active_record do
      require "activerecord-postgres-hstore/activerecord"
    end
  end
  rake_tasks do
#    load "tasks/paperclip.rake"
  end
end

require "activerecord-postgres-hstore/hstore"
require "activerecord-postgres-hstore/string"
require "activerecord-postgres-hstore/hash"
