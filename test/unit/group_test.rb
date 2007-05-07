require File.dirname(__FILE__) + '/../test_helper'

class GroupTest < Test::Unit::TestCase
  fixtures :groups, :contacts, :contacts_groups

  def test_truth
    nexus10 = groups(:nexus10)
    assert_not_nil nexus10
    assert_instance_of Group, nexus10
    assert_valid nexus10
    assert nexus10.errors.empty?
  end
  
  def test_display_name
    assert_equal 'Nexus 10', groups(:nexus10).display_name
    assert_equal 'BrainHouse', groups(:brainhouse).display_name
  end
  
  def test_habtm_contacts
    brainhouse = groups(:brainhouse)
    assert_not_nil brainhouse.contacts
    assert_equal 2, brainhouse.contacts.size
    brainhouse.contacts.each {|contact|
      subtest_contact contact
    }
    assert brainhouse.contacts.include?(contacts(:renat))
    assert brainhouse.contacts.include?(contacts(:yura))
    assert !brainhouse.contacts.include?(contacts(:thomas))

    nexus10 = groups(:nexus10)
    assert_not_nil nexus10.contacts
    assert_equal 1, nexus10.contacts.size
    nexus10.contacts.each {|contact|
      subtest_contact contact
    }
    assert !nexus10.contacts.include?(contacts(:renat))
    assert !nexus10.contacts.include?(contacts(:yura))
    assert nexus10.contacts.include?(contacts(:thomas))
  end
   
  def subtest_contact(contact)
    assert_instance_of Contact, contact
    assert_valid contact
    assert contact.errors.empty?
  end
  
  
  
  
end
