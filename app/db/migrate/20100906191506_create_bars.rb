class CreateBars < ActiveRecord::Migration
  def self.up
    create_table :bars do |t|
      t.hstore :data
      t.timestamps
    end
  end

  def self.down
    drop_table :bars
  end
end
