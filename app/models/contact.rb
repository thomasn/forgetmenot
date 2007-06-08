# Author:: Renat Akhmerov (mailto:renat@brainhouse.ru)
# Author:: Yury Kotlyarov (mailto:yura@brainhouse.ru)
# License:: MIT License

require 'fileutils'

class Contact < ActiveRecord::Base
  has_and_belongs_to_many :activities
  has_and_belongs_to_many :groups
  belongs_to :address
  belongs_to :address2, :class_name => 'Address', :foreign_key => 'address2_id'
  belongs_to :lead_source

  private

  def dynamic_attribute_value(a)
    if self.id.nil?
      if new_dynamic_attribute_values.has_key?(a.name.to_sym) 
        value = new_dynamic_attribute_values[a.name.to_sym]
      else 
        value = DynamicAttributeValue.new :dynamic_attribute_id => a.id
        new_dynamic_attribute_values[a.name.to_sym] = value
      end
    else
      if new_dynamic_attribute_values.has_key?(a.name.to_sym) 
        value = new_dynamic_attribute_values[a.name.to_sym]
      else 
        value = DynamicAttributeValue.find_by_dynamic_attribute_id_and_contact_id(a.id, self.id)   
        value = DynamicAttributeValue.new :dynamic_attribute_id => a.id, :contact_id => self.id if value.nil?
        new_dynamic_attribute_values[a.name.to_sym] = value
      end
    end
    value
  end
  
  def self.do_acts_as_ferret(attrs = DynamicAttribute.find(:all))
    acts_as_ferret :additional_fields => attrs.collect { |a| a.name.to_sym }
    # FIXME: workaround here - drop following line
    attrs.each { |a| aaf_index.ferret_index.options[:default_field] << a.name }
    drop_index_dir
  end

  def self.drop_index_dir
    if File.exists?(aaf_index.ferret_index.options[:path])
      begin
        aaf_index.close
      rescue
      end
      FileUtils.rm_rf(aaf_index.ferret_index.options[:path])
    end
  end

  public

  def new_dynamic_attribute_values
    @new_dynamic_attribute_values ||= {}
  end
  
  # moved from private part of class for test only
  def self.create_attributes
    attrs = DynamicAttribute.find(:all)
    attrs.each { |a| create_attribute(a, false) }
    do_acts_as_ferret attrs
  end

  def self.create_attribute(a, recreate_index = true)
    # defining getter method
    define_method a.name do
      dynamic_attribute_value(a).send("#{a.type_name}_value")
    end

    # defining setter method
    define_method "#{a.name}=" do |new_value|
      dynamic_attribute_value(a).send("#{a.type_name}_value=", new_value)
    end

    do_acts_as_ferret if recreate_index
  end

  create_attributes
  acts_as_taggable
  after_create { |c| c.new_dynamic_attribute_values.values.each { |v| v.contact_id = c.id; v.save }  }
  after_update { |c| c.new_dynamic_attribute_values.values.each { |v| v.save }  }

  def display_name
    !self.first_name.nil? || !self.last_name.nil? ? "#{self.first_name} #{self.last_name}".strip : "contact ##{self.id}"
  end

  alias_method :old_column_for_attribute, :column_for_attribute
  def column_for_attribute(method_name)
    obj = old_column_for_attribute(method_name)
    obj.nil? ? DynamicAttribute.find_by_name(method_name).column : obj
  end

end

