class Activity < ActiveRecord::Base
  belongs_to :activity_type
  has_and_belongs_to_many :contacts
  
  def display_name
    result = self.activity_type_id.nil? ? "activity ##{self.id}" : self.activity_type.display_name
    result += ' at ' + self.occured_at.strftime('%d/%m/%y %H:%M') unless self.occured_at.nil?
    result
  end
end
