# Author:: Renat Akhmerov (mailto:renat@brainhouse.ru)
# Author:: Yury Kotlyarov (mailto:yura@brainhouse.ru)
# License:: MIT License

class AddingUserIdForActivities < ActiveRecord::Migration
  def self.up
    add_column :activities, :user_id, :integer
  end

  def self.down
    remove_column :activities, :user_id
  end
end
