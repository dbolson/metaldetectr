class CreateLastfmArtists < ActiveRecord::Migration
  def self.up
    create_table :lastfm_artists do |t|
      t.integer :user_id
      t.string :name

      t.timestamps
    end

    # adding an index because we're going to do a lot of searches against the releases table
    # adding a unique constraint because a user will not have multiple records with the same artist.
    add_index :lastfm_artists, [ :user_id, :name ], :unique => true
  end

  def self.down
    drop_table :lastfm_artists
  end
end
