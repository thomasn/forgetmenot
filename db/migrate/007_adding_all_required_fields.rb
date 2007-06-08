# Author:: Renat Akhmerov (mailto:renat@brainhouse.ru)
# Author:: Yury Kotlyarov (mailto:yura@brainhouse.ru)
# License:: MIT License

class AddingAllRequiredFields < ActiveRecord::Migration
  def self.up
    # contacts
    add_column :contacts, :title, :string
    add_column :contacts, :work_phone, :string
    add_column :contacts, :mobile_phone, :string
    add_column :contacts, :home_phone, :string
    add_column :contacts, :other_phone, :string
    add_column :contacts, :fax, :string
    add_column :contacts, :do_not_email, :boolean
    add_column :contacts, :do_not_phone, :boolean
    add_column :contacts, :notes, :text
    
    # groups
    add_column :groups, :account_number, :integer
    add_column :groups, :phone, :string
    add_column :groups, :fax, :string
    add_column :groups, :website, :string
    add_column :groups, :notes, :text
  end

  def self.down
    # contacts
    drop_column :contacts, :title
    drop_column :contacts, :work_phone
    drop_column :contacts, :mobile_phone
    drop_column :contacts, :home_phone
    drop_column :contacts, :other_phone
    drop_column :contacts, :fax
    drop_column :contacts, :do_not_email
    drop_column :contacts, :do_not_phone
    drop_column :contacts, :notes
    
    # groups
    drop_column :groups, :account_number
    drop_column :groups, :phone
    drop_column :groups, :fax
    drop_column :groups, :website
    drop_column :groups, :notes
  end
end
