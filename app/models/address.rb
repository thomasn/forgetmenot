class Address < ActiveRecord::Base
  
  def display_name
    result = [self.address1, self.address2, self.city, self.state, self.zip, self.country].compact.join(", ")
    result.empty? ? "address ##{self.id}" : result
  end
end
