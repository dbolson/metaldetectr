class AddLastfmUsernameToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :lastfm_username, :string
  end

  def self.down
    remove_column :users, :lastfm_username
  end
end
