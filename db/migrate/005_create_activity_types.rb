# Author:: Renat Akhmerov (mailto:renat@brainhouse.ru)
# Author:: Yury Kotlyarov (mailto:yura@brainhouse.ru)
# License:: MIT License

class CreateActivityTypes < ActiveRecord::Migration
  def self.up
    create_table :activity_types do |t|
      t.column :name, :string
    end
  end

  def self.down
    drop_table :activity_types
  end
end
