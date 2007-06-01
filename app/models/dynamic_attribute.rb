class DynamicAttribute < ActiveRecord::Base
  after_create { |a| Contact.create_attribute(a) }
end
