class CreateActivities < ActiveRecord::Migration
  def self.up
    create_table :activities do |t|
      t.column :activity_type_id, :integer
      t.column :occured_at, :datetime
      t.column :description, :string
    end
  end

  def self.down
    drop_table :activities
  end
end
