# Author:: Renat Akhmerov (mailto:renat@brainhouse.ru)
# Author:: Yury Kotlyarov (mailto:yura@brainhouse.ru)
# License:: MIT License

class OneMoreIndexForDynamicAttributes < ActiveRecord::Migration
  def self.up
    add_index :dynamic_attributes, :name
  end

  def self.down
    remove_index :dynamic_attributes, :name
  end
end
