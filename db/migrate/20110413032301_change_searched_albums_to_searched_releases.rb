class ChangeSearchedAlbumsToSearchedReleases < ActiveRecord::Migration
  def self.up
    rename_table :searched_albums, :searched_releases
  end

  def self.down
    rename_table :searched_releases, :searched_albums
  end
end
