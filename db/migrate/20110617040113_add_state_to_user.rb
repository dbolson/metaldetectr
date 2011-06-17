class AddStateToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :state, :string, :null => false, :default => 'default'
  end

  def self.down
    remove_column :users, :state
  end
end
