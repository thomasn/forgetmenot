require File.dirname(__FILE__) + '/../test_helper'

class ActivityTest < Test::Unit::TestCase
  fixtures :contacts, :activities, :activities_contacts, :activity_types
  
  def test_truth
    a = Activity.find(activities(:renat_and_yura_call_out).id)
    assert_not_nil a
    assert_instance_of Activity, a
    assert_valid a
    assert a.errors.empty?
    assert_equal activities(:renat_and_yura_call_out), a
  end                          

  def test_display_name
    a = Activity.find(activities(:renat_and_yura_call_out).id)
    assert_equal "#{a.activity_type.display_name} at #{a.occured_at.strftime('%d/%m/%y %H:%M')}", a.display_name
    
    a = Activity.create
    assert_equal "activity ##{a.id}", a.display_name
    now = Time.now
    a = Activity.create :occured_at => now
    assert_equal "activity ##{a.id} at #{now.strftime('%d/%m/%y %H:%M')}", a.display_name
    a = Activity.create :activity_type_id => 1
    assert_equal 'Email in', a.display_name
  end

  def test_habtm_contacts
    a = Activity.find(activities(:renat_and_yura_call_out).id)
    assert_not_nil a.contacts
    assert_equal 2, a.contacts.size
    a.contacts.each {|c|
      subtest_contact c
    }
    assert !a.contacts.include?(contacts(:thomas))
    assert a.contacts.include?(contacts(:yura))
  end
  
  def test_belongs_to_activity_type
    a = Activity.find(activities(:renat_and_yura_call_out).id)
    assert_not_nil a.activity_type
    assert_equal 4, a.activity_type.id
  end
  
  def subtest_contact(contact)
    assert_instance_of Contact, contact
    assert_valid contact
    assert contact.errors.empty?
  end
end
