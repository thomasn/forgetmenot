# Author:: Renat Akhmerov (mailto:renat@brainhouse.ru)
# Author:: Yury Kotlyarov (mailto:yura@brainhouse.ru)
# License:: MIT License

class CreateGroups < ActiveRecord::Migration
  def self.up
    create_table :groups do |t|
      t.column :name, :string
    end
  end

  def self.down
    drop_table :groups
  end
end
