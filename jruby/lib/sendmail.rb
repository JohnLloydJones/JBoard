require 'rubygems'
require 'net/smtp'
require 'lib/encrypt.rb'

module Board
   class SendMail
      include Encrypt

      def initialize( host, port )
         @host = host
         @port = port
      end
      def send_email(props, to, to_alias, subject)
         from = props['emailfrom']
         if !props['emailuser'].empty?
            emailuser = props['emailuser']
            emailpass = props['emailpassword']
            emailpass = decrypt( emailpass ) if !emailpass.empty?   
         else
            emailuser = nil
            emailpass = nil
         end

         puts "will use #{@host}:#{@port} and login #{emailuser}"
         time_now = Time.new
         msg = <<END_OF_MESSAGE
Date: #{time_now}
From: #{props['emailalias']} <#{from}>
Reply-To: <#{from}>
To: #{to_alias} <#{to}>
Bcc: #{emailuser}@#{@host} <board email user>
Message-Id: <#{time_now.to_i}@#{@host}>
Subject: #{subject}

#{props['emailbody']}

END_OF_MESSAGE

         puts "Sending email: #{subject} to #{to} from: #{props['emailalias']} <#{from}>"
         smtp = Net::SMTP.new(@host, @port.to_i)
#         smtp.set_debug_output $stdout
         smtp.start( @host, emailuser, emailpass, :login ) do |s|
            s.send_message( msg, from, to )
         end
      end
   end

end

