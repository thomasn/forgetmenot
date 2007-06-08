# Author:: Renat Akhmerov (mailto:renat@brainhouse.ru)
# Author:: Yury Kotlyarov (mailto:yura@brainhouse.ru)
# License:: MIT License

class AddContactsGroupsTable < ActiveRecord::Migration
  def self.up
    create_table :contacts_groups, :id => false do |t|
      t.column :contact_id, :integer
      t.column :group_id, :integer
    end
  end

  def self.down
    drop_table :contacts_groups
  end
end
