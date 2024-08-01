require 'net/smtp'
require 'optparse'

def send_test_email(smtp_server, port, sender, recipient, username, password)
  message = <<~END_OF_MESSAGE
    From: #{sender}
    To: #{recipient}
    Subject: Test Email

    This is a test email.
  END_OF_MESSAGE

  begin
    Net::SMTP.start(smtp_server, port, 'localhost', username, password, :login) do |smtp|
      smtp.send_message message, sender, recipient
    end
    puts "Test email sent successfully!"
  rescue => e
    puts "An error occurred: #{e.message}"
  end
end

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: ruby smtp_test.rb [options]"

  opts.on("--server SERVER", "SMTP server address") { |v| options[:server] = v }
  opts.on("--port PORT", Integer, "SMTP server port") { |v| options[:port] = v }
  opts.on("--sender SENDER", "Sender email address") { |v| options[:sender] = v }
  opts.on("--recipient RECIPIENT", "Recipient email address") { |v| options[:recipient] = v }
  opts.on("--username USERNAME", "SMTP username") { |v| options[:username] = v }
  opts.on("--password PASSWORD", "SMTP password") { |v| options[:password] = v }
end.parse!

if options.values.any?(&:nil?)
  puts "Error: All options are required."
  puts OptionParser.new.help
  exit 1
end

send_test_email(options[:server], options[:port], options[:sender], options[:recipient], options[:username], options[:password])
