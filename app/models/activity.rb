class Activity < ActiveRecord::Base
  
  belongs_to :activity_type
  has_and_belongs_to_many :contacts
  belongs_to :user
  has_many :email_messages # FIXME: here must be has_one association
  
  before_create { |a| a.time = Time.now  }
  
  def display_name
    result = self.activity_type_id.nil? ? "activity ##{self.id}" : self.activity_type.display_name
    result += ' at ' + self.time.strftime('%d/%m/%y %H:%M') unless self.time.nil?
    result
  end
end
