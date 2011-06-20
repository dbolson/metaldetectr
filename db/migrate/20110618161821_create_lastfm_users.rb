class CreateLastfmUsers < ActiveRecord::Migration
  def self.up
    create_table :lastfm_users do |t|
      t.references :user
      t.references :release
      t.string :name

      t.timestamps
    end

    # adding an index because we're going to do a lot of searches against the releases table
    # adding a unique constraint because a user will not have multiple records with the same artist.
    add_index :lastfm_users, [ :user_id, :name ], :unique => true
    execute "ALTER TABLE `lastfm_users` ADD CONSTRAINT `fk_lastfm_users_users` FOREIGN KEY `fk_lastfm_users_users` (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE"
  end

  def self.down
    drop_table :lastfm_users
  end
end
