class DynamicAttribute < ActiveRecord::Base
  has_many :dynamic_attribute_values  
  after_create { |a| Contact.create_attribute(a) }
end
