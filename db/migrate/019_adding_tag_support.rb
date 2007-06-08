# Author:: Renat Akhmerov (mailto:renat@brainhouse.ru)
# Author:: Yury Kotlyarov (mailto:yura@brainhouse.ru)
# License:: MIT License

class AddingTagSupport < ActiveRecord::Migration
  def self.up
    create_table :tags, :force => true do |t|
      t.column :name, :string
    end
  
    create_table :taggings, :force => true do |t|
      t.column :tag_id, :integer
      t.column :taggable_id, :integer
      t.column :taggable_type, :string
      t.column :created_at, :datetime
    end
  end

  def self.down
    drop_table :tags
    drop_table :taggings
  end
end
