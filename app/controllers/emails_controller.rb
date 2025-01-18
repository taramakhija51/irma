class EmailsController < ApplicationController
  include NodemailerHelper

  def send_thank_you
    recipient = params[:email]
    subject = "Thank You for Connecting!"
    body = "It was great to meet you. Let's stay in touch!"

    send_email_with_nodemailer(recipient, subject, body)
  end
end
