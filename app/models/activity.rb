class Activity < ActiveRecord::Base
  belongs_to :activity_type
  has_and_belongs_to_many :contacts
  
  def display_name
    result = self.occured_at.strftime('%d/%m/%y %H:%M')
    result = self.activity_type.display_name + " at " + result unless self.activity_type.nil?
    result
  end
end
