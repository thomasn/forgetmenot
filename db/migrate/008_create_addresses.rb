class CreateAddresses < ActiveRecord::Migration
  def self.up
    create_table :addresses do |t|
      t.column :address1, :string
      t.column :address2, :string
      t.column :city, :string
      t.column :state, :string
      t.column :zip, :string
      t.column :country, :string
    end
    
    add_column :contacts, :address_id, :integer
    add_column :contacts, :address2_id, :integer
    
    add_column :groups, :billing_address_id, :integer
    add_column :groups, :shipping_address_id, :integer
  end

  def self.down
    drop_table :addresses
    
    remove_column :contacts, :address_id
    remove_column :contacts, :address2_id
    
    remove_column :groups, :billing_address_id
    remove_column :groups, :shipping_address_id
  end
end
