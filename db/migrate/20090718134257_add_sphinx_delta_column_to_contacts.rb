class AddSphinxDeltaColumnToContacts < ActiveRecord::Migration
def self.up
  add_column :contacts, :delta, :boolean, :default => true,
    :null => false
end
  
  def self.down
    remove_column :articles, :delta
  end
end
