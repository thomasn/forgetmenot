# Author:: Renat Akhmerov (mailto:renat@brainhouse.ru)
# Author:: Yury Kotlyarov (mailto:yura@brainhouse.ru)
# License:: MIT License

require File.dirname(__FILE__) + '/../test_helper'

class ActivityTest < ActiveSupport::TestCase
  fixtures :dynamic_attributes, :dynamic_attribute_values, :contacts, :activities, :activities_contacts, :activity_types, :email_messages
  
  def test_truth
    a = Activity.find(activities(:renat_and_yura_call_out).id)
    assert_not_nil a
    assert_instance_of Activity, a
    assert a.valid?
    assert a.errors.empty?
    assert_equal activities(:renat_and_yura_call_out), a
  end                          

  def test_display_name
    a = Activity.find(activities(:renat_and_yura_call_out).id)
    assert_equal "[multiple contacts]: #{a.activity_type.display_name} at #{a.time.strftime('%d/%m/%y %H:%M')}", a.display_name

    a = Activity.find(activities(:thomas_call_in).id)
    assert_equal "Nichols, Thomas: #{a.activity_type.display_name} at #{a.time.strftime('%d/%m/%y %H:%M')}", a.display_name

    a = Activity.create
    assert_equal "activity ##{a.id} at #{a.time.strftime('%d/%m/%y %H:%M')}", a.display_name
    now = Time.now
    a = Activity.create :time => now
    assert_equal "activity ##{a.id} at #{now.getutc.strftime('%d/%m/%y %H:%M')}", a.display_name  # TODO use local times
    a = Activity.create :activity_type_id => 1
    assert_equal "Email in at #{a.time.strftime('%d/%m/%y %H:%M')}", a.display_name
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

  def test_hm_email_messages
    a = Activity.find(activities(:renat_and_yura_call_out).id)
    assert_not_nil a.email_messages
    assert_equal 1, a.email_messages.size
    a.email_messages.each {|m|
      subtest_email_message m
    }
    assert !a.contacts.include?(contacts(:thomas))
    assert a.contacts.include?(contacts(:yura))
  end

  def test_taggable
    assert !Activity.find(:first).taggable?
    assert !Activity.taggable?
  end

  def subtest_contact(contact)
    assert_instance_of Contact, contact
    assert contact.valid?
    assert contact.errors.empty?
  end
  
  def subtest_email_message(message)
    assert_instance_of EmailMessage, message
    assert message.valid?
    assert message.errors.empty?
  end
end
