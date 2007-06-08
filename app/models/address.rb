class Address < ActiveRecord::Base
  
  def display_name
    result = [self.address1, self.address2, self.city, self.state, self.zip, self.country].select{|a| !a.nil? && !a.empty?}.compact.join(", ")
    result = self.city + ': ' + result if !self.city.nil? && !self.city.empty?
    result.empty? ? "address ##{self.id}" : result
  end
end
