# Author:: Renat Akhmerov (mailto:renat@brainhouse.ru)
# Author:: Yury Kotlyarov (mailto:yura@brainhouse.ru)
# License:: MIT License

class DynamicAttribute < ActiveRecord::Base

  after_create { |a| Contact.create_attribute(a) }

  def type
    self.type_name.to_sym
  end

  def column
    ActiveRecord::ConnectionAdapters::Column.new(self.name, nil, self.type_name)
  end
end

