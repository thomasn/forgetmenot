class ContactMailer < ActionMailer::Base

  def email(email_message, sent_on = Time.now)
    @subject = email_message.subject
    @body = {}
    @body["email_message"] = email_message
    @recipients = email_message.activity.contacts.collect { |c| c.email }.sort { |a, b| a <=> b }
    @from       = 'renat@brainhouse.ru'
    @sent_on    = sent_on
    @headers    = {}
  end
end
