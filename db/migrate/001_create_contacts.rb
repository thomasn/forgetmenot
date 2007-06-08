# Author:: Renat Akhmerov (mailto:renat@brainhouse.ru)
# Author:: Yury Kotlyarov (mailto:yura@brainhouse.ru)
# License:: MIT License

class CreateContacts < ActiveRecord::Migration
  def self.up
    create_table :contacts do |t|
      t.column :first_name, :string
      t.column :last_name, :string
      t.column :email, :string
      t.column :phone_number, :string
    end
  end

  def self.down
    drop_table :contacts
  end
end
