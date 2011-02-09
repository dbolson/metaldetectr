class CreateAlbumLinks < ActiveRecord::Migration
  def self.up
    create_table :album_links do |t|
      t.string :page
      t.string :url

      t.timestamps
    end
  end

  def self.down
    drop_table :album_links
  end
end
