# Author:: Renat Akhmerov (mailto:renat@brainhouse.ru)
# Author:: Yury Kotlyarov (mailto:yura@brainhouse.ru)
# License:: MIT License

require File.dirname(__FILE__) + '/../test_helper'

class ContactMailerTest < Test::Unit::TestCase
  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures'
  CHARSET = "utf-8"
  
  fixtures :dynamic_attributes, :dynamic_attribute_values, :email_messages, :activities, :contacts, :activities_contacts, :activity_types

  include ActionMailer::Quoting

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []

    @expected = TMail::Mail.new
    @expected.set_content_type "text", "plain", { "charset" => CHARSET }
    @expected.mime_version = '1.0'
  end

  def test_send
    email_message = EmailMessage.find(email_messages(:email_to_yura_and_renat).id)
    @expected.from = "renat@brainhouse.ru"
    @expected.to = "renat@brainhouse.ru, yura@brainhouse.ru"
    @expected.subject = email_message.subject
    @expected.body    = email_message.body
    @expected.date    = Time.now
    
    assert_equal @expected.encoded, ContactMailer.create_email(email_message, @expected.date).encoded
  end

  private
    def read_fixture(action)
      IO.readlines("#{FIXTURES_PATH}/contact_mailer/#{action}")
    end

    def encode(subject)
      quoted_printable(subject, CHARSET)
    end
end
