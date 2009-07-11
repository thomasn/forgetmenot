# Author:: Renat Akhmerov (mailto:renat@brainhouse.ru)
# Author:: Yury Kotlyarov (mailto:yura@brainhouse.ru)
# License:: MIT License

require File.dirname(__FILE__) + '/../test_helper'

class LeadSourceTest < Test::Unit::TestCase
  ## CLEANUP - all fixtures preloaded ## fixtures :dynamic_attributes, :dynamic_attribute_values, :lead_sources, :contacts

  def test_truth
    s = LeadSource.find(lead_sources(:internet).id)
    assert_not_nil s
    assert_instance_of LeadSource, s
    assert_valid s
    assert s.errors.empty?
    assert_equal lead_sources(:internet), s
  end                          

  def test_display_name
    s = LeadSource.find(lead_sources(:internet).id)
    assert_equal s.name, s.display_name
    
    s = LeadSource.create
    assert_equal "lead source ##{s.id}", s.display_name
  end

  def test_habtm_contacts
    s = LeadSource.find(lead_sources(:internet).id)
    assert_not_nil s.contacts
    assert_equal 2, s.contacts.size
    s.contacts.each {|c|
      subtest_contact c
    }
    assert !s.contacts.include?(contacts(:thomas))
    assert s.contacts.include?(contacts(:renat))
    assert s.contacts.include?(contacts(:yura))
  end
  
  def subtest_contact(contact)
    assert_instance_of Contact, contact
    assert_valid contact
    assert contact.errors.empty?
  end
end
