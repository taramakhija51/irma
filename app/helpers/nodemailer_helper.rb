require 'open3'

module NodemailerHelper
  def send_email_with_nodemailer(to, subject, text)
    command = "node nodemailer_service/mailer.js '#{to}' '#{subject}' '#{text}'"
    stdout, stderr, status = Open3.capture3(command)
    
    if status.success?
      puts "Email sent successfully: #{stdout}"
    else
      puts "Error sending email: #{stderr}"
    end
  end
end
