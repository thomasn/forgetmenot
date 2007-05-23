class ActiveRecord::Base
  SKIP_COLUMN_LIST = %w{ lft rgt parent_id root_id depth }
  
  def display_name
    self.respond_to?(:name) && self.name.nil? ? "#{self.class.name.underscore.humanize.downcase} ##{self.id}" : self.name
  end
  
  def get_multiple_associations(show_when_associated_table_is_empty = false)
    self.class.get_multiple_associations(show_when_associated_table_is_empty)
  end
  
  def self.get_multiple_associations(show_when_associated_table_is_empty = false)
    ( reflect_on_all_associations(:has_and_belongs_to_many) + 
      reflect_on_all_associations(:has_many)).select {|a| 
        show_when_associated_table_is_empty || a.class_name.constantize.count > 0 }
  end
  
  def get_single_associations(show_when_associated_table_is_empty = false)
    self.class.get_single_associations(show_when_associated_table_is_empty)
  end
  
  def self.get_single_associations(show_when_associated_table_is_empty = false)
    reflect_on_all_associations(:belongs_to).select {|a| 
      show_when_associated_table_is_empty || a.class_name.constantize.count > 0}
  end

  def get_entity_columns
    self.class.get_entity_columns
  end  
  
  def self.get_entity_columns
    content_columns.select {|c| !SKIP_COLUMN_LIST.include?(c.name)}
  end  

  def hierarchical?
    self.class.hierarchical?
  end
  
  def self.hierarchical?
    respond_to? :parent_id
  end
  
  def searchable?
    self.class.searchable?
  end

  def self.searchable?
    !instance_methods.find {|m| m =~ /ferret/}.nil?
  end

end

