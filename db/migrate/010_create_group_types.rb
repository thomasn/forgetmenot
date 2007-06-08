# Author:: Renat Akhmerov (mailto:renat@brainhouse.ru)
# Author:: Yury Kotlyarov (mailto:yura@brainhouse.ru)
# License:: MIT License

class CreateGroupTypes < ActiveRecord::Migration
  def self.up
    create_table :group_types do |t|
      t.column :name, :string
    end
    
    add_column :groups, :group_type_id, :integer
  end

  def self.down
    drop_table :group_types

    remove_column :groups, :group_type_id
  end
end
