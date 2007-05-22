class Group < ActiveRecord::Base
  has_and_belongs_to_many :contacts
  belongs_to :billing_address, :class_name => 'Address', :foreign_key => 'billing_address_id'
  belongs_to :shipping_address, :class_name => 'Address', :foreign_key => 'shipping_address_id'
  belongs_to :group_type
  
  acts_as_threaded
end
