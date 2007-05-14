class Contact < ActiveRecord::Base
  has_and_belongs_to_many :activities
  has_and_belongs_to_many :groups
  belongs_to :address
  belongs_to :address2, :class_name => 'Address', :foreign_key => 'address2_id'
  belongs_to :lead_source
  
  def display_name
    !self.first_name.nil? || !self.last_name.nil? ? "#{self.first_name} #{self.last_name}".strip : "contact ##{self.id}"
  end
end
