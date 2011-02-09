class CreateSearchedAlbums < ActiveRecord::Migration
  def self.up
    create_table :searched_albums do |t|
      t.integer :album_link_id

      t.timestamps
    end
  end

  def self.down
    drop_table :searched_albums
  end
end
