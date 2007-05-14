class Group < ActiveRecord::Base
  has_and_belongs_to_many :contacts
  
  def display_name
    self.name.nil? ? "group ##{self.id}" : self.name
  end
end
