class ContactMailer < ActionMailer::Base

  def send(action, email_message)
    @subject = email_message.subject
    @body["email_message"] = email_message
    @recipients = email_message.activity.contacts.collect { |c| c.email }.sort { |a, b| a <=> b }
    @from       = 'renat@brainhouse.ru'
    @sent_on    = Time.now
    @headers    = {}
  end
end
