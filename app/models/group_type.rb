class GroupType < ActiveRecord::Base
  has_many :groups
  
  def display_name
    self.name.nil? ? "group type ##{self.id}" : self.name
  end
end
