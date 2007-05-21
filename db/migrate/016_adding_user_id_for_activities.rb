class AddingUserIdForActivities < ActiveRecord::Migration
  def self.up
    add_column :activities, :user_id, :integer
  end

  def self.down
    remove_column :activities, :user_id
  end
end
