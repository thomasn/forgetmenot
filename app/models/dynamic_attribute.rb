class DynamicAttribute < ActiveRecord::Base
  after_create { |a| Contact.create_attribute(a) }
  def type
    self.type_name.to_sym
  end
end
  