class CreateDynamicAttributeValues < ActiveRecord::Migration
  def self.up
    create_table :dynamic_attribute_values do |t|
      t.column :dynamic_attribute_id, :integer
      t.column :contact_id, :integer
      t.column :string_value, :string
      t.column :text_value, :text
      t.column :integer_value, :integer
      t.column :decimal_value, :decimal
      t.column :datetime_value, :datetime
      t.column :boolean_value, :boolean
    end
  end

  def self.down
    drop_table :dynamic_attribute_values
  end
end
