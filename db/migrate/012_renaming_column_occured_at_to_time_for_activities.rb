# Author:: Renat Akhmerov (mailto:renat@brainhouse.ru)
# Author:: Yury Kotlyarov (mailto:yura@brainhouse.ru)
# License:: MIT License

class RenamingColumnOccuredAtToTimeForActivities < ActiveRecord::Migration
  def self.up
    rename_column :activities, :occured_at, :time
  end

  def self.down
    rename_column :activities, :time, :occured_at
  end
end
