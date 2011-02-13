class CreateCompletedSteps < ActiveRecord::Migration
  def self.up
    create_table :completed_steps do |t|
      t.integer :step

      t.timestamps
    end
  end

  def self.down
    drop_table :completed_steps
  end
end
