# Author:: Renat Akhmerov (mailto:renat@brainhouse.ru)
# Author:: Yury Kotlyarov (mailto:yura@brainhouse.ru)
# License:: MIT License

class ActiveRecord::Base
  SKIP_COLUMN_LIST = %w{ lft rgt parent_id root_id depth taggings }
  
  def display_name
    self.respond_to?(:name) && self.name.nil? ? "#{self.class.name.underscore.humanize.downcase} ##{self.id}" : self.name
  end
  
  def get_multiple_associations(show_when_associated_table_is_empty = false)
    self.class.get_multiple_associations(show_when_associated_table_is_empty)
  end
  
  def self.get_multiple_associations(show_when_associated_table_is_empty = false)
    ( reflect_on_all_associations(:has_and_belongs_to_many) + 
      reflect_on_all_associations(:has_many)).select {|a| 
        (show_when_associated_table_is_empty || a.class_name.constantize.count > 0) && !SKIP_COLUMN_LIST.include?(a.name.to_s) && !a.through_reflection }
  end

  def get_has_many_through_associations(show_when_associated_table_is_empty = false)
    self.class.get_has_many_through_associations(show_when_associated_table_is_empty)
  end

  def self.get_has_many_through_associations(show_when_associated_table_is_empty = false)
    reflect_on_all_associations(:has_many).select {|a| 
        (show_when_associated_table_is_empty || a.class_name.constantize.count > 0) && !SKIP_COLUMN_LIST.include?(a.name.to_s) && a.through_reflection }
  end

  def get_single_associations(show_when_associated_table_is_empty = false)
    self.class.get_single_associations(show_when_associated_table_is_empty)
  end
  
  def self.get_single_associations(show_when_associated_table_is_empty = false)
    reflect_on_all_associations(:belongs_to).select {|a| 
      (show_when_associated_table_is_empty || a.class_name.constantize.count > 0) && !SKIP_COLUMN_LIST.include?(a.name.to_s)}
  end

  def get_entity_columns
    self.class.get_entity_columns
  end  
  
  def self.get_entity_columns
    content_columns.select { |c| !SKIP_COLUMN_LIST.include?(c.name) }
  end  

  def hierarchical?
    self.class.hierarchical?
  end
  
  def self.hierarchical?
    columns.find { |c| c.name == 'parent_id' } ? true : false
  end
  
  def searchable?
    self.class.searchable?
  end

  def self.searchable?
    !instance_methods.find { |m| m =~ /ferret/ }.nil?
  end

  def emailable?
    self.class.emailable?
  end
  
  def self.emailable?
    content_columns.find { |c| c.name == 'email' } ? true : false
  end

  def taggable?
    self.class.taggable?
  end
  
  def self.taggable?
    respond_to? :find_tagged_with
  end

end

