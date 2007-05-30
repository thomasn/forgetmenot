class Contact < ActiveRecord::Base
  has_and_belongs_to_many :activities
  has_and_belongs_to_many :groups
  belongs_to :address
  belongs_to :address2, :class_name => 'Address', :foreign_key => 'address2_id'
  belongs_to :lead_source

  def self.create_attribute(a) 
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
  end
  
  def self.create_attributes
    DynamicAttribute.find(:all).each { |a| create_attribute(a) }
  end
  
  acts_as_ferret
  create_attributes
  acts_as_taggable
  
  def display_name
    !self.first_name.nil? || !self.last_name.nil? ? "#{self.first_name} #{self.last_name}".strip : "contact ##{self.id}"
  end
  
end
