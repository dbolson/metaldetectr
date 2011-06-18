class AddIndexesToReleases < ActiveRecord::Migration
  def self.up
    add_index :releases, :band
  end

  def self.down
    remove_index :releases, :band
  end
end
