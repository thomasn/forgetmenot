require 'fileutils'

class Contact < ActiveRecord::Base
  has_and_belongs_to_many :activities
  has_and_belongs_to_many :groups
  belongs_to :address
  belongs_to :address2, :class_name => 'Address', :foreign_key => 'address2_id'
  belongs_to :lead_source

  private

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

  # moved from private part of class for test only
  def self.create_attributes
    attrs = DynamicAttribute.find(:all)
    attrs.each { |a| create_attribute(a, false) }
    do_acts_as_ferret attrs
  end

  def self.create_attribute(a, recreate_index = true)
    define_method a.name do
      value = DynamicAttributeValue.find_by_dynamic_attribute_id_and_contact_id(a.id, self.id) 
      return nil unless value
      value.send("#{a.type_name}_value")
    end

    define_method "#{a.name}=" do |new_value|
      value = DynamicAttributeValue.find_or_create_by_dynamic_attribute_id_and_contact_id(a.id, self.id)
      value.update_attribute("#{a.type_name}_value", new_value)
      ferret_update
    end

    do_acts_as_ferret if recreate_index
  end

  create_attributes
  acts_as_taggable

  def display_name
    !self.first_name.nil? || !self.last_name.nil? ? "#{self.first_name} #{self.last_name}".strip : "contact ##{self.id}"
  end

  alias_method :old_column_for_attribute, :column_for_attribute
  def column_for_attribute(method_name)
    obj = old_column_for_attribute(method_name)
    obj.nil? ? DynamicAttribute.find_by_name(method_name).column : obj
  end


end

