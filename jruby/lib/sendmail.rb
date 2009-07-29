require 'rubygems'
require 'net/smtp'
require 'lib/encrypt.rb'

module Board
   class SendMail
      include Encrypt

      def initialize url
         @url = url
      end
      def send_email(props, to, to_alias, subject)
         from = props['emailfrom']
         emailhost = props['emailhost']
         emailport = props['emailport']
         if !props['emailuser'].empty?
            emailuser = props['emailuser']
            emailpass = props['emailpassword']
            emailpass = decrypt( emailpass ) if !emailpass.empty?   
         else
            emailuser = nil
            emailpass = nil
         end

         puts "will use #{emailhost}:#{emailport} and login #{emailuser}"
         time_now = Time.new
         msg = <<END_OF_MESSAGE
From: #{props['emailalias']} <#{from}>
Reply-To: <#{from}>
To: #{to_alias} <#{to}>
Subject: #{subject}
Date: #{time_now}
Message-Id: <#{time_now.to_i}@#{emailhost}>

#{props['emailbody']}

END_OF_MESSAGE

         puts "Sending email: #{subject} to #{to} from: #{props['emailalias']} <#{from}>"
         smtp = Net::SMTP.new(emailhost, emailport.to_i)
#         smtp.set_debug_output $stdout
         smtp.start( emailhost, emailuser, emailpass, :login ) do |s|
            s.send_message( msg, from, to )
         end
      end
   end

end

