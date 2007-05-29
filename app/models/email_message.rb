class EmailMessage < ActiveRecord::Base
  belongs_to :activity
  
  def display_name
    if self.subject.nil? || self.subject.empty?
      if self.activity.nil? || self.activity.contacts.empty?
        result = id_str
      else
        result = to_str
      end
    else
      if self.activity.nil? || self.activity.contacts.empty?
        result = "#{id_str}"
      else
        result = "#{to_str}"
      end
      result += "; #{subject_str}"
    end
    return result
  end
  
  private
  
  def id_str
    "email message ##{self.id}"
  end
  
  def subject_str
    "Subject: #{self.subject}"
  end

  def to_str
    "To: #{self.activity.contacts.sort { |a, b| a.email <=> b.email }.collect { |c| c.email }.join(', ')}"
  end
end
