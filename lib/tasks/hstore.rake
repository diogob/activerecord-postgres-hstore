namespace :hstore do
  desc "Setup hstore extension into the database"
  task 'setup' do
    ActiveRecord::Base.connection.execute "CREATE EXTENSION IF NOT EXISTS hstore"
  end
end
Rake::Task["db:schema:load"].enhance(["hstore:setup"])
