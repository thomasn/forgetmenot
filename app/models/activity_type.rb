class ActivityType < ActiveRecord::Base
  has_many :activities
  
  def display_name
    self.name
  end
end
