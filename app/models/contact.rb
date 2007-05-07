class Contact < ActiveRecord::Base
  has_and_belongs_to_many :groups
  
  def display_name
    "#{self.first_name} #{self.last_name}"
  end
end
