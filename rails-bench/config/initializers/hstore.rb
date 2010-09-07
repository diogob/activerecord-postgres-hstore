#initializer "active_record.postgres.hstore" do
  ActiveSupport.on_load(:active_record) do
 #   raise "HERE"
    require 'activerecord-postgres-hstore'
  end
#end 

