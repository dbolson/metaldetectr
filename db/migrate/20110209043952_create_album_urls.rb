class CreateAlbumUrls < ActiveRecord::Migration
  def self.up
    create_table :album_urls do |t|
      t.integer :page
      t.string :url

      t.timestamps
    end
  end

  def self.down
    drop_table :album_urls
  end
end
