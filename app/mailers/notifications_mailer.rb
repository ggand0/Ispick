class NotificationsMailer < ActionMailer::Base
  default :from => "noreply@ispick.dev"
  default :to => CONFIG['gmail_username']

  def new_message(message)
    @message = message
    mail(:subject => "[Ispick.tld] #{message.subject}")
  end
end
