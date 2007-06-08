# Author:: Renat Akhmerov (mailto:renat@brainhouse.ru)
# Author:: Yury Kotlyarov (mailto:yura@brainhouse.ru)
# License:: MIT License

class AddingRootIdAndDepthForGroups < ActiveRecord::Migration
  def self.up
    add_column :groups, :root_id, :integer
    add_column :groups, :depth, :integer
  end

  def self.down
    remove_column :groups, :root_id
    remove_column :groups, :depth
  end
end
