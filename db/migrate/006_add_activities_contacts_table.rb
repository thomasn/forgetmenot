# Author:: Renat Akhmerov (mailto:renat@brainhouse.ru)
# Author:: Yury Kotlyarov (mailto:yura@brainhouse.ru)
# License:: MIT License

class AddActivitiesContactsTable < ActiveRecord::Migration
  def self.up
    create_table :activities_contacts, :id => false do |t|
      t.column :activity_id, :integer
      t.column :contact_id, :integer
    end
  end

  def self.down
    drop_table :activities_contacts
  end
end
