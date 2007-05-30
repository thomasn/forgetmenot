class DynamicAttributeValue < ActiveRecord::Base
  belongs_to :contact
  belongs_to :dynamic_attribute
end
