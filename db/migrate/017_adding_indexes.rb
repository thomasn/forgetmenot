# Author:: Renat Akhmerov (mailto:renat@brainhouse.ru)
# Author:: Yury Kotlyarov (mailto:yura@brainhouse.ru)
# License:: MIT License

class AddingIndexes < ActiveRecord::Migration
  def self.up
    add_index :activities, :activity_type_id
    add_index :activities, :user_id

    add_index :activities_contacts, :activity_id
    add_index :activities_contacts, :contact_id

    add_index :contacts, :address_id
    add_index :contacts, :address2_id
    add_index :contacts, :lead_source_id
    
    add_index :contacts_groups, :contact_id
    add_index :contacts_groups, :group_id

    add_index :groups, :billing_address_id
    add_index :groups, :shipping_address_id
    add_index :groups, :group_type_id
    add_index :groups, :parent_id
    add_index :groups, :root_id
    add_index :groups, :lft
    add_index :groups, :rgt

    add_index :users, [ :login, :crypted_password ]
  end

  def self.down
    remove_index :activities, :activity_type_id
    remove_index :activities, :user_id

    remove_index :activities_contacts, :activity_id
    remove_index :activities_contacts, :contact_id

    remove_index :contacts, :address_id
    remove_index :contacts, :address2_id
    remove_index :contacts, :lead_source_id
    
    remove_index :contacts_groups, :contact_id
    remove_index :contacts_groups, :group_id

    remove_index :groups, :billing_address_id
    remove_index :groups, :shipping_address_id
    remove_index :groups, :group_type_id
    remove_index :groups, :parent_id
    remove_index :groups, :root_id
    remove_index :groups, :lft
    remove_index :groups, :rgt

    remove_index :users, [ :login, :crypted_password ]
  end
end
