# Author:: Renat Akhmerov (mailto:renat@brainhouse.ru)
# Author:: Yury Kotlyarov (mailto:yura@brainhouse.ru)
# License:: MIT License

class CreateLeadSources < ActiveRecord::Migration
  def self.up
    create_table :lead_sources do |t|
      t.column :name, :string
    end
    
    add_column :contacts, :lead_source_id, :integer
  end

  def self.down
    drop_table :lead_sources
    
    remove_column :contacts, :lead_source_id
  end
end
