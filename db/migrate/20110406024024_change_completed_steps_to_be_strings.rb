class ChangeCompletedStepsToBeStrings < ActiveRecord::Migration
  def self.up
    change_column :completed_steps, :step, :string
  end

  def self.down
    change_column :completed_steps, :step, :integer
  end
end
