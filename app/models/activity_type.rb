class ActivityType < ActiveRecord::Base
  has_many :activities
  
  def display_name
    self.name.nil? ? "activity type ##{self.id}" : self.name
  end
end
