class CreateReleases < ActiveRecord::Migration
  def self.up
    create_table :releases do |t|
      t.string :name
      t.string :band
      t.string :format
      t.string :label
      t.string :url
      t.datetime :us_date
      t.datetime :euro_date

      t.timestamps
    end
  end

  def self.down
    drop_table :releases
  end
end
