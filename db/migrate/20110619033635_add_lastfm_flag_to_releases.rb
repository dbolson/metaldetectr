class AddLastfmFlagToReleases < ActiveRecord::Migration
  def self.up
    add_column :releases, :last_fm, :boolean, :default => false
  end

  def self.down
    remove_column :releases, :last_fm
  end
end
