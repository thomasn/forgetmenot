require 'fileutils'
class Contact < ActiveRecord::Base
  has_and_belongs_to_many :activities
  has_and_belongs_to_many :groups
  belongs_to :address
  belongs_to :address2, :class_name => 'Address', :foreign_key => 'address2_id'
  belongs_to :lead_source

  def self.do_acts_as_ferret(dyn_attrs = DynamicAttribute.find(:all))
    drop_index_dir
    attrs = Contact.content_columns.collect { |c| c.name.to_sym }
    acts_as_ferret :fields => (attrs + dyn_attrs.collect { |a| a.name.to_sym })
  end
  
  def self.drop_index_dir
    if File.exists?('index')
      begin
        Contact.aaf_index.close 
      rescue
      end
      FileUtils.rm_rf('index')
    end
  end
  
  def self.create_attribute(a, recreate_index = true)
    define_method a.name do
      value = DynamicAttributeValue.find_by_dynamic_attribute_id_and_contact_id(a.id, self.id) 
      return nil unless value
      value.send("#{a.type_name}_value")
    end

    define_method "#{a.name}=" do |new_value|
      value = DynamicAttributeValue.find_by_dynamic_attribute_id_and_contact_id(a.id, self.id) 
      value = DynamicAttributeValue.new(:contact_id => self.id, :dynamic_attribute_id => a.id) if value.nil?
      value.update_attribute("#{a.type_name}_value", new_value)
    end
    
    do_acts_as_ferret if recreate_index
  end
  
  def self.create_attributes
    attrs = DynamicAttribute.find(:all)
    attrs.each { |a| create_attribute(a, false) }
    do_acts_as_ferret attrs
  end
  
  create_attributes
  acts_as_taggable
  
  def display_name
    !self.first_name.nil? || !self.last_name.nil? ? "#{self.first_name} #{self.last_name}".strip : "contact ##{self.id}"
  end
end
