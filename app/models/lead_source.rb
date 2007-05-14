class LeadSource < ActiveRecord::Base
  has_many :contacts
  
  def display_name
    self.name.nil? ? "lead source ##{self.id}" : self.name
  end
end
