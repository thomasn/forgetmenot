require File.dirname(__FILE__) + '/../test_helper'

class EmailMessageTest < Test::Unit::TestCase
  fixtures :email_messages, :activities, :activity_types, :activities_contacts, :contacts

  def test_truth
    message = email_messages(:email_to_yura_and_renat)
    assert_not_nil message
    assert_instance_of EmailMessage, message
    assert_valid message
    assert message.errors.empty?
  end                          
  
  def test_display_name
    assert_equal "To: #{contacts(:renat).email}, #{contacts(:yura).email}; Subject: #{email_messages(:email_to_yura_and_renat).subject}",
      EmailMessage.find(email_messages(:email_to_yura_and_renat).id).display_name
    m = EmailMessage.create
    assert_equal "email message ##{m.id}", m.display_name
    m = EmailMessage.create :subject => 'Forgetmenot'
    assert_equal "email message ##{m.id}; Subject: Forgetmenot", m.display_name
    m = EmailMessage.create :activity_id => activities(:renat_and_yura_email_out).id
    assert_equal "To: #{contacts(:renat).email}, #{contacts(:yura).email}", m.display_name
  end

  def test_bt_activity
    m = EmailMessage.find(email_messages(:email_to_yura_and_renat).id)
    assert_not_nil m.activity
    assert_equal 1, m.activity.id
    subtest_activity(m.activity)
  end
  
  def subtest_activity(activity)
    assert_instance_of Activity, activity
    assert_valid activity
    assert activity.errors.empty?
  end
end
