# Author:: Renat Akhmerov (mailto:renat@brainhouse.ru)
# Author:: Yury Kotlyarov (mailto:yura@brainhouse.ru)
# License:: MIT License

class CreateDynamicAttributes < ActiveRecord::Migration
  def self.up
    create_table :dynamic_attributes do |t|
      t.column :name, :string
      t.column :type_name, :string
    end
  end

  def self.down
    drop_table :dynamic_attributes
  end
end
