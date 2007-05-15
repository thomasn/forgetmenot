class RenamingFieldsDescriptionToNotesAndChangingTypeToText < ActiveRecord::Migration
  def self.up
    remove_column :activities, :description
    add_column :activities, :notes, :text
  end
  
  def self.down
    remove_column :activities, :notes
    add_column :activities, :description, :string
  end
end
