require 'rubygems'
gem 'camping'
require 'camping'
require 'time'
require 'yaml'
require 'lib/bbcode'
require 'lib/encrypt'
require 'lib/sendmail'
require 'lib/mimetypes'
require 'lib/views'

import 'java.util.HashMap'
import 'java.util.Date'
import 'net.jlj.board.dom.Category'
import 'net.jlj.board.dom.Forum'
import 'net.jlj.board.dom.Topic'
import 'net.jlj.board.dom.Post'
import 'net.jlj.board.dom.Message'
import 'net.jlj.board.dom.Member'
import 'net.jlj.board.dom.Event'
import 'net.jlj.board.dom.Link'
import 'net.jlj.board.Facade'

Camping.goes :Board

module UserSession
    def service(*a)
        m = /^(\/.*?)(?=\/)/.match(@root)
        @root = m[1] if m      # fix for Camping quirk that expects the app to live at root
        session = env['java.servlet_request'].session true
        @state = session['state'] || Camping::H[]
        @user = session['user_login'] || Board::User.new( 'guest' )
        @state.user_name = @user.login
        @req_url = env['java.servlet_request'].request_url
        
        # TODO: check the HTTP_X_FORWARDED_FOR header in case the request was proxied.
        @user_ip = env['java.servlet_request'].remote_addr
        @styles = %w{ board.css }
        @scripts = %w{ board.js }
        @state.errors, @state.next_errors = @state.next_errors || [], nil
        session['state'] = @state
        @headers['Content-Type'] = 'text/html; charset=utf-8'
        @facade = Facade.get_instance @user.login
        begin
           super(*a)
        ensure
           @facade.close if @facade
        end
    end
end

# Fix some bugs in the Markaby 0.50 gem
Markaby::XHTMLTransitional.tagset[:th] += [:width, :height, :bgcolor]
Markaby::XHTMLTransitional.doctype = ["-//W3C//DTD XHTML 1.0 Transitional//EN",
                                      "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"]
class Markaby::Builder
   def xhtml_html(&block)
      instruct! if @output_xml_instruction
      declare!(:DOCTYPE, :html, :PUBLIC, *tagset.doctype)
      @streams.last.to_s + tag!(:html, :xmlns => "http://www.w3.org/1999/xhtml", "xml:lang" => "en", :lang => "en", &block)
   end
end
# ... and turn off the <?XML tag -- hurts IE -- and emit readable html while debugging
Markaby::Builder.set(:output_xml_instruction, false)
Markaby::Builder.set(:indent, 3) 

module Board
    include UserSession
    include MimeTypes
    
    STATIC_PATH = File.expand_path('../..', File.dirname(__FILE__))
    APP_NAME = STATIC_PATH[/\/([^\/]+)$/]
    @@properties ||= YAML::load( File.open( STATIC_PATH + '/WEB-INF/board.yaml' ) )

    def board_properties
       @@properties
    end
    # app_root is obsolete -- remove any remaining references and delete.
    def app_root
      @app_root ||= "#{'http://' + @env.HTTP_HOST +  Board::APP_NAME}"
    end
    class User
      attr_accessor :login, :errors, :state, :group, :validated, :uid
      def initialize login
         @login = login
         @errors = Errors.new
         @state = 'unregistered'
         @group = 'guest'
         @validated = false
         @uid = 0
      end
      def validated?
         @validated
      end
    end
    class Errors
       attr_accessor :errors
       
       def initialize
         @errors = {}
       end
       
       def add(attribute, message = nil)
         message ||= :invalid
         message = generate_message(attribute, message) if message.is_a?(Symbol)
         @errors ||= {}
         @errors[attribute.to_s] ||= []
         @errors[attribute.to_s] << message
       end
       def any?
          ! @errors.empty?
       end
       def each_full
          full_messages.each { |msg| yield msg }
       end
       def full_messages(options = {})
          full_messages = []

          @errors.each_key do |attr|
             @errors[attr].each do |message|
                next unless message
                if attr == "base"
                   full_messages << message
                else
                   attr_name = attr.to_s
                   full_messages << attr_name + ' ' + message
                end
             end
          end
          full_messages
       end

       def generate_message(attribute, message = :invalid)
         message.to_s
       end
    
    end
end

class Date
    def to_default_s
        strftime("%B %d, %Y at %H:%M")
    end
end

module Board::Controllers
  class Index < R '/'
    def get
      return redirect('/board')
    end
  end
    class LoginUser < R '/login'
      include Encrypt
        def get
            session = env['java.servlet_request'].session true
            session['user_login'] = @user
            @user ||= User.new 'guest'
            @title = 'login'
            @scripts << "validate.js"
            render :login
        end
        def post
            @login = true

            session = env['java.servlet_request'].session true
            if @facade.validate_user( @input.login, encrypt( @input.password ) )
                member = @facade.get_user @input.login
                @user = User.new member.name
                @user.state = member.state
                @user.group = member.group
                @user.validated = true
                @user.uid = member.get_id
                session['user_login'] = @user
                @state.user_name = member.name
                target = "/personal/#{member.get_id}"
                if member.name == 'admin'
                  board = @facade.get_board
                  @input.referrer = nil if board.categories.empty?
                end
                target = member.properties["user_home"] if member.properties["user_home"]
                target = @input.referrer if @input.referrer
                
                return redirect( target )
            else
                @user = User.new 'guest'
                @user.errors.add(:password, 'does not match the entered user name.')
                session['user_login'] = @user
            end
            render :login
        end
    end

    class LogoutUser < R '/logout'
        def get
            session = env['java.servlet_request'].session true
            session['user_login'] = User.new 'guest'
            @state.clear
            redirect("./board")
        end
    end
    class UpdateSettings < R '/board_settings'
       include Encrypt
       def get
          if @user.group != 'admin'
             return redirect '/login'
          end
          @board = @facade.get_board
          render :board_settings
       end
       def post
          @board = @facade.get_board
          @facade.begin_tx
          @board.properties['smtp_host'] = @input.smtp_host 
          @board.properties['smtp_user'] = @input.smtp_user 
          if @input.smtp_password != ' ~secret~ '
             password = @input.smtp_password
             password = encrypt( password ) if ! password.empty?
             @board.properties['smtp_password'] = password
          end
          @board.properties['reg_question'] = @input.reg_question 
          @board.properties['reg_answer'] = @input.reg_answer
          @facade.commit
          return redirect "/personal/#{@user.uid}"
       end
    end
   class RegisterUser < R '/register'
      include Encrypt
      def get
         @board = @facade.get_board
         @scripts << "validate.js"
         @title = 'register'
         render :register
      end
     def post
        @login = true
        session = env['java.servlet_request'].session true
        @board = @facade.get_board
        
        @user = User.new 'guest'
        if !@input.agree
           @user.errors.add(:base, "You must check the agree box")
        end
        if !@input.reg_quest =~ @board.properties['reg_answer']
           @user.errors.add(:base, "You must answer the Security Question correctly.")
        end
        if @input.password != @input.password_check
           @user.errors.add(:base, "Your passwords must match exactly")
        end
        if @facade.get_user( @input.username )
           @user.errors.add(:base, "User #{@input.username} already exists.")
        end
        if @facade.get_user_by_email( @input.useremail )
           @user.errors.add(:base, "The email supplied has already been used.")
        end
        
        if @user.errors.any?
           session['user_login'] = @user
           return render :register
        end
        member = Member.new
        member.name = @input.username
        member.password = encrypt @input.password
        member.email = @input.useremail
        member.state = 'validating'
        member.group = 'user'
        reg_code = encrypt( @input.username )
        member.reg_code = reg_code
        @facade.persist member
        session['user_login'] = User.new @input.username
        begin
           if  @board.properties['smtp_host']
              host = @board.properties['smtp_host'].split(':')
              board_properties['emailhost'] = host[0]
              board_properties['emailport'] = host.length > 1 ? host[1] : '25'   
              board_properties['emailuser'] = @board.properties['smtp_user']
              board_properties['emailpassword'] = @board.properties['smtp_password']
                 
              # Fix plus signs as they will be urldecoded to spaces.
              url = "#{app_root}/confirm?reg_key=#{ reg_code.gsub( /\+/, "%2B" ) }"
              sm = SendMail.new url
              sm.send_email( board_properties, @input.useremail, 'New User', 'Confirm registration' )
           end
           @facade.commit
        rescue Exception => e
           puts "send_email failed: #{ e } (#{ e.class })!"
           @user.errors.add(:base, "Failed to send email to #{@input.useremail}.")
           return render :register
        end
        redirect ('/board')
     end
  end
  class Members < R '/members|/members(.*?)'
     def get key
        puts "get w/key"
        @members = key.nil? ? @facade.get_all_members : @facade.get_members( "%"+key+"%" )
        @members.each do |member|
            member.properties['num_posts'] = @facade.get_number_of_posts member.name
        end
        @title = 'members'
        render :members
     end
  end
=begin
  class ApproveMember < R '/approve_member/(.*?)'
     def get name
        if @user.group != 'admin'
           return redirect('./login')
        end
        member = @facade.get_user name
        if %w{validating moderated}.includes? member.state
           member.state = 'registered'
           @facade.commit
        end
     end
  end
=end
   # Ajax : returns text directly
   class UpdateMember < R '/update_member/(.*?)'
      def post id
         puts "update_member/#{id}"
         if @user.group != 'admin'
            return "Error: you must login as an admin to use this function."
         end
         @facade.begin_tx
         member = @facade.get_user id.to_i
         puts "user_state: #{@input.user_state}"
         puts "user_group: #{@input.user_group}"
         member.state = @input.user_state if @input.user_state
         member.group = @input.user_group if @input.user_group

         @facade.send_system_message( member.name,  
             "#{member.name}, your status has been changed to #{member.state}.",
             "state change for #{member.name}")
         
         @facade.commit
         "OK: User was updated successfully"
      end
   end
   # Ajax : returns text directly
   class AddModerator < R '/add_moderator'
      def get
         "Not available"
      end
      def post
         if @user.group != 'admin'
            return "Error: you must log in as an admin to use this function."
          end
          @facade.begin_tx
         
          category = @facade.get_category @input.category.to_i
          member = @facade.get_user @input.new_mod
          if member && %{registered}.include?( member.state ) && !category.moderator?( member.name )
             category.add_moderator( member )
             @facade.send_system_message( member.name,  
                 "#{member.name}, you are now a moderator for category #{category.title}.",
                 "#{member.name} moderator for #{category.title}")
             @facade.commit
             
             "OK: #{member.name} was added as moderator for #{category.title}"
          else
             "Error: could not add the moderator."
          end
      end 
   end
   # Ajax : returns text directly
   class DelModerator < R '/del_moderator'
      def get
         "Not available"
      end
      def post
         if @user.group != 'admin'
            return "Error: you must log in as an admin to use this function."
          end
          @facade.begin_tx
         
          category = @facade.get_category @input.category.to_i
          member = @facade.get_user @input.old_mods
          if category.moderator?( member.name )
             category.remove_moderator( member )
             
             @facade.send_system_message( member.name,  
                 "#{member.name}, you have been removed as a moderator for category #{category.title}.",
                 "#{member.name} removed as moderator for #{category.title}")
                 
             @facade.commit
             
             "OK: #{member.name} was removed as moderator for #{category.title}"
          else
             "Error: could not remove the moderator."
          end
      end 
   end
   class Personal < R '/personal/(\d+)'
      def get id
         @member = @facade.get_user id.to_i
         @member.properties ||= {}
         @member.properties['num_posts'] = @facade.get_number_of_posts @member.name
         @board = @facade.get_board
         @num_forums = 0
         @num_topics = 0
         @board.categories.each do |category|
            @num_forums += category.forums.size
            category.forums.each { |f|
               @num_topics += f.topics.size if f.topics
            } 
         end
         @events = []
         if @member.name == @user.login
            user = @user.login
         else
            user = ' public '
         end
         @facade.get_events_for_user( user ).each do |e|
            m = @facade.get_message( e.getObjectId ); # NB e.object_id gets the Ruby ID NB
            e.properties = {}
            user = @facade.get_user( e.created_by )
            e.properties['author_id'] = user.get_id
            e.properties['author_state'] = user.get_state
            e.properties['body'] = m.body if m;
            @events << e
         end
         dt = Date.new
         dt = Date.new( dt.year, dt.month, dt.day - 14 )
         @posts = []
         @facade.get_posts_for_user( @member.name, dt ).each {|p| @posts << p}
         @member.friends.each do |friend|
            @facade.get_posts_for_user( friend.name, dt ).each {|p| @posts << p} 
         end
       
         @posts.each do |post|
            begin
               topic = @facade.get_topic_for_post post.get_id
            rescue
               next
            end   
            e = Event.new
            e.post = post
            e.created_by = post.created_by
            e.created = post.created
            e.properties = {}
            e.properties['post'] = post
            e.properties['topic_title'] = topic.title
            e.properties['topic_id'] = topic.get_id
            e.properties['post_id'] = post.get_id
            user = @facade.get_user( post.created_by )
            e.properties['author_id'] = user.get_id
            e.properties['author_state'] = user.get_state
            @events << e
         end
         @events.sort! {|a,b| b.created <=> a.created}
         @scripts << "personal.js" << "dom.js" << "httpclient.js"
         @styles << "ppage.css"
         @title = "#{@member.name}'s page"
         render :personal
     end
     def post id
        msg = @input['short-message']
        if @input["type"] == "public"
           @facade.post_public_message( msg )
        elsif @input["type"] == "private"
           @facade.send_private_message( @input["recipient"].split(','), msg )
        end
        @facade.commit
        
        redirect("#{app_root}/personal/#{id}")
     end
  end
   # Ajax : returns text directly
  class AddFriend < R '/add_friend'
     def post
        name = @input.friend
        user = @facade.get_user name
        if user
           @facade.send_system_message( name, 
           "User #{@user.login} wants to be your friend.",
           "friend request for #{name}")
           @facade.commit
           "OK: User #{name} has been notified and must accept your request before being added to you friends list."
        else
           "Error: could not find user #{name}"
        end
     end
  end
   # Ajax : returns text directly
  class ConfirmFriend < R '/confirm_friend'
     def post
        id = @input.event
        answer = @input.answer

        event = @facade.get_event id.to_i
        if event.for_user == @user.login
           if answer == 'Y'
              member = @facade.get_user event.created_by
              friend = @facade.get_user event.for_user
              friend.add_friend member
              member.add_friend friend
              event.set_text "accepted friend request"
              
              @facade.send_private_message( [member.name, ], "User #{@user.login} has accepted your request to be your friend." )
              
              @facade.commit
              "OK: #{member.name} and you are now friends"
           else
              @facade.begin_tx
              msg = @facade.get_message( event.getObjectId )
              msg.body = "Sorry, user #{user.login} did not accept your offer of friendship."
              event.set_private_message( msg, member )
              event.set_text "rejected friend request"
              @facade.commit
              "OK: #{member.name} has been informed that you do not want to be friends"
           end
        else
           "Error: only user #{event.for_user} can accept this request"
        end
     end
  end
   # Ajax : returns text directly
   class AddPlace < R '/add_place'
     def post
        link = Link.new( @input.link_url, @input.link_text )
        link.set_description @input.description
        @facade.add_link link
        @facade.commit
        "OK: Your list of places has been updated" 
     end
   end
   # Ajax : returns text directly
   class RemovePlace < R '/remove_place'
     def post
        link = @facade.get_link @input.link_oid.to_i
        @facade.remove_link link
        @facade.commit
        "OK: Your list of places has been updated" 
     end
   end
   class Profile < R '/profile/(\d+)'
      def get id
         @member = @facade.get_user id.to_i
         @scripts << "profile.js" << "dom.js" << "httpclient.js"
         render :profile
      end
      def post
      end
   end
   class ChangePassword < R '/changePassword'
      include Encrypt
      def post
         ret = "Error: failed to change password for #{@user.login}"
         new = @input['new-password']
         old = @input['old-password']
         begin
             if @facade.validate_user( @user.login, encrypt( old ) )
                @facade.begin_tx
                user = @facade.get_user( @user.login )
                user.password = encrypt( new )
                @facade.commit
                ret = "OK: Changed password"
             end
          rescue
             ret = "Error: password not changed!"
             puts $!
          end
          ret
      end
   end
   class ChangeAvatar < R '/changeAvatar'
      include Encrypt
      def post
         ret = "Error: failed to change avatar"
         sig = @input['sig']
         begin
            member = @facade.get_user( @user.login )
            if %{registered}.include? @user.state
               @facade.begin_tx
               member = @facade.get_user @user.login
               member.avatar = @input.newavatar
               @facade.commit
               ret = "OK: Changed avatar"
            end
         rescue
            ret = "Error: avatar not changed!"
            puts $!
         end
         ret
      end
   end
   class ChangeSignature < R '/changeSignature'
      include Encrypt
      def post
         ret = "Error: failed to change signature"
         sig = @input['sig']
         begin
            member = @facade.get_user( @user.login )
            if %{registered}.include? @user.state
               @facade.begin_tx
               member = @facade.get_user @user.login
               member.sig = @input.newsig
               @facade.commit
               ret = "OK: Changed signature"
            end
         rescue
            ret = "Error: signature not changed!"
            puts $!
         end
         ret
      end
   end
   
  class PmUser < R '/pm_user'
     def post
        @facade.send_private_message( [ @input.pm_for ], @input.short_msg )
        @facade.commit
        "OK: Your PM was sent to #{@input.pm_for}"
     end
  end
  class ConfirmUser < R '/confirm'
      include Encrypt
     def get
        reg_key = @input.reg_key
        user_login = decrypt( reg_key ).strip

        session = env['java.servlet_request'].session true
        session['user_login'] = @user

        @facade.begin_tx
        user = @facade.get_user user_login
        user.reg_code = nil
        user.state = 'moderated'
        @facade.persist user
        @facade.commit

        redirect ('/login')
        end
  end
  class ViewBoard < R '/board'
     def get
        @login_name = @user.login
        
        @board = @facade.get_board
        @num_categories = @board.categories.size
        @num_forums = 0
        @num_topics = 0
        @num_pending = 0
        @board.categories.each do |category|
           @num_forums += category.forums.size
           @num_pending += category.pending_posts.size if category.pending_posts
          
           category.forums.each do |forum|
              @num_topics += forum.topics.size if forum.topics
              forum.properties ||= {}

              last_posted_topic = forum.properties['last_posted_topic']

              forum.topics.each do |topic|
                 last_posted_topic ||= topic
                 next if topic.state == 'hidden'
                 last_post = @facade.get_last_post_for_topic( topic.get_id )
                 topic.last_post_date = last_post.created
                 topic.last_post_author = last_post.created_by
                 if (topic.last_post_date.nil? ||
                    (topic.last_post_date >= last_posted_topic.last_post_date))
                    last_posted_topic = topic
                 end
              end if forum.topics.size > 0
              forum.properties['last_posted_topic'] = last_posted_topic
              forum.properties['last_posted_topic_id'] = last_posted_topic.get_id if last_posted_topic
              forum.properties['last_posted_topic_num_posts'] = last_posted_topic.posts.size if last_posted_topic
           end
        end
        @scripts << "category.js" << "dom.js" << "httpclient.js"
        @title = 'home'
        render :board
     end
  end
  class ViewCategory < R '/category/(\d+)'
     def get id
        begin
           @category = @facade.get_category id.to_i
           @num_forums = @category.forums.size
        rescue
           @not_found_msg = "The requested category was not found. Maybe it has been moved or deleted."
           return render :not_found 
        end
        @num_topics = 0
        @num_pending = @category.pending_posts.size if @category.pending_posts
        @category.forums.each do |forum|
           @num_topics += forum.topics.size if forum.topics
           forum.properties ||= {}

           last_posted_topic = forum.properties['last_posted_topic']

           forum.topics.each do |topic|
              topic.properties ||= {}
              last_posted_topic ||= topic
              next if topic.state == 'hidden'
              last_post = @facade.get_last_post_for_topic( topic.get_id )
              topic.last_post_date = last_post.created
              topic.last_post_author = last_post.created_by
              if (topic.last_post_date.nil? ||
                 (topic.last_post_date >= last_posted_topic.last_post_date))
                 last_posted_topic = topic
              end
           end if forum.topics.size > 0
           forum.properties['last_posted_topic'] = last_posted_topic
           forum.properties['last_posted_topic_id'] = last_posted_topic.get_id if last_posted_topic
        end
        @scripts << "category.js" << "dom.js" << "httpclient.js"
        @title = @category.title
        render :category
     end
  end
  class ViewPending < R '/pending/(\d+)'
     def get id
        @category = @facade.get_category id.to_i
        @pending = @category.pending_posts
        @pending.each do |post|
           post.properties['author'] = @facade.get_user( post.created_by )
           post.properties['body'] = @facade.get_message( post.body_id )
           post.properties['topic'] = @facade.get_topic post.properties['topic_id'].to_i
        end
        @title = 'pending'
        render :pending
     end
     def post id
     end
  end
  class ViewForum < R '/forum/(\d+)'
     def get( id )
        begin
           @forum = @facade.get_forum id.to_i
           @category = @facade.get_category_for_forum id.to_i
        rescue
           @not_found_msg = "The requested forum was not found. Maybe it has been moved or deleted."
           return render :not_found 
        end
        @num_pages = (@forum.topics.size + 14) / 15
        @page = @input.p || '1'
        pg = @page.to_i
        offset = (pg - 1) * 15
        @topics = @facade.get_topics_for_forum( @forum.get_id.to_i, offset, 15 )
        last_posted_topic = nil
        @topics.each do |topic|
           topic.properties ||= {}
           next if topic.state == 'hidden'
           last_posted_topic ||= topic
           if (topic.last_post_date.nil? ||
              (topic.last_post_date >= last_posted_topic.last_post_date))
              last_posted_topic = topic
           end
           last_post = @facade.get_last_post_for_topic( topic.get_id )
           topic.last_post_id = last_post.get_id
           topic.last_post_date = last_post.created
           topic.last_post_author = last_post.created_by
           topic.num_replies = topic.posts.size() -1
        end
        @forum.properties['last_posted_topic'] = last_posted_topic
        @forum.properties['last_posted_topic_id'] = last_posted_topic.get_id if last_posted_topic
        @title = @forum.title
        render :forum
     end
  end

  class ViewTopic < R '/topic/(\d+)'
     def get( id )
        begin
           @forum = @facade.get_forum_for_topic id.to_i
           @topic = @facade.get_topic id.to_i
           @category = @facade.get_category_for_topic id.to_i
           @topic.last_post_id = @facade.get_last_post_for_topic( id.to_i ).get_id
        rescue
           @not_found_msg = "The requested topic was not found. Maybe it has been moved or deleted."
           return render :not_found 
        end
        @num_pages = (@topic.posts.size + 9) / 10
        @page = @input.p || '1'
        pg = @page.to_i
        offset = (pg - 1) * 10
        @posts = @facade.get_posts_for_topic( @topic.get_id.to_i, offset, 10 )
        @posts.each do |post|
           post.properties ||= {}
           post.properties['author'] = @facade.get_user( post.created_by )
           post.properties['body'] = @facade.get_message( post.body_id )
           post.properties['num_posts'] = @facade.get_number_of_posts post.created_by

        end
        @scripts << "topic.js" << "dom.js" << "httpclient.js"
        @title = @topic.title
        render :topic
     end
  end
  class DeleteTopic < R '/delete_topic/(\d+)'
     def get id
        @topic = @facade.get_topic id.to_i
        @category = @facade.get_category_for_topic @topic.get_id.to_i
        if ! (@facade.is_admin || @category.moderators.include?( @user.login ) )
           return redirect '/login'
        end
        @forum = @facade.get_forum_for_topic( id.to_i )
        @facade.begin_tx
        @forum.remove_topic( @topic )
        @forum.add_to_deleted( @topic )
        @facade.commit
        redirect "/forum/#{@forum.get_id}"
     end
  end
  # Ajax : returns text directly
  class ReportPost < R '/report_post'
     def post
        @post = @facade.get_post @input.p_id.to_i
        @topic = @facade.get_topic_for_post @input.p_id.to_i
        url = "#{@input.page_url}#p#{@input.p_id}" 
        @facade.report_post (@input.p_id.to_i, "Reported [url=#{url}]post[/url] in topic [b]#{@topic.title}[/b]\n by user #{@user.login}.\nReason given: #{@input.reason}")
        @facade.commit
        "OK: Thank you. Your report has been sent to the moderator(s)"
     end
  end
  class DeletePost < R '/delete_post/(\d+)'
     def get id
        @facade.begin_tx
        @post = @facade.get_post id.to_i
        @topic = @facade.get_topic_for_post id.to_i
        @category = @facade.get_category_for_topic @topic.get_id.to_i
        if ! (@facade.is_admin || @category.moderators.include?( @user.login ) )
           return redirect '/login'
        end
        @topic.remove_post @post
        @category.add_to_deleted @post
        @facade.commit
        redirect "#{app_root}/topic/#{@topic.get_id}"
     end
  end
   class ApprovePost < R '/approve_post/(\d+)'
      def get id
         @post = @facade.get_post id.to_i
         @topic = @facade.get_topic @post.properties["topic_id"].to_i
         @category = @facade.get_category_for_topic @topic.get_id.to_i
         if ! (@facade.is_admin || @category.moderators.include?( @user.login ) )
            return redirect '/login'
         end
         @facade.approve_post id.to_i
         @facade.commit
         redirect "/topic/#{@topic.get_id}"
      end
   end
   class RejectPost < R '/reject_post/(\d+)'
      def get id
         @post = @facade.get_post id.to_i
         @topic = @facade.get_topic @post.properties["topic_id"].to_i
         @category = @facade.get_category_for_topic @topic.get_id.to_i
         if ! (@facade.is_admin || @category.moderators.include?( @user.login ) )
            return redirect '/login'
         end
         
         @topic.remove_post @post
         @category.add_to_deleted @post
         @post.properties["rejected_by"] = @user.login
            
         @facade.commit
         redirect "/topic/#{@topic.get_id}"
      end
   end
  class EditPost < R '/edit/(\d+)'
     def get( id )
        @topic = @facade.get_topic_for_post id.to_i
        @posts = @topic.get_posts
        @post_id = id
        @posts.each do |post|
           post.properties ||= {}
           post.properties['author'] = @facade.get_user( post.created_by )
           post.properties['body'] = @facade.get_message( post.body_id )
        end
        @post = @facade.get_post( id.to_i )
        msg = @facade.get_message( @post.body_id )
        @body = msg.body
        @scripts << "editcode.js" << "editextra.js"
        render :edit
     end
     
     def post( id )
        topic = @facade.get_topic( @input.t_id.to_i )
        post = @facade.get_post( @input.p_id.to_i )
        
        topic.last_post_date = Date.new
        msg = Message.new
        msg.body = @input.postbody
        msg.created_by = @user.login
        
        @facade.persist msg
        @facade.flush
        
        post.body_id = msg.get_id
        @facade.commit
        
        redirect "/topic/#{@input.t_id}#p#{@input.p_id}"
     end
  end
  class NewTopic  < R '/newtopic/(\d+)'
     def get id
        @forum = @facade.get_forum id.to_i
        @topic_id = 0
        @post_id = 0
        
        @body = ""

        @scripts << "editcode.js" << "editextra.js"
        @title = 'new topic'
        render :edit
     end
     def post id
        topic = Topic.new
        topic.title = @input.topic_title
        topic.description = @input.topic_desc

        @facade.add_topic( @input.f_id.to_i, topic, @input.postbody || "empty post" )
        
        @facade.commit
        redirect "/forum/#{@input.f_id}"
     end
  end
  class NewPost < R '/newpost/(\d+)'
     def get id
        if !@facade.has_post_rights
           return redirect "/login"
        end
        
        @topic = @facade.get_topic id.to_i
        @posts = @topic.get_posts
        @topic_id = id
        @post_id = 0
        @posts.each do |post|
           post.properties ||= {}
           post.properties['author'] = @facade.get_user( post.created_by )
           post.properties['body'] = @facade.get_message( post.body_id )
        end
        @body = ""

        @scripts << "editcode.js" << "editextra.js"
        @title = 'new post'
        render :edit
     end
     def post id
        @facade.add_post(id.to_i, @input.postbody || "empty post")
        @facade.commit

        redirect "#{app_root}/topic/#{@input.t_id}"
     end
  end
  class QuotePost < R '/quote/(\d+)'
     def get id
        if !@facade.has_post_rights
           return redirect "/login"
        end
        @topic = @facade.get_topic_for_post id.to_i
        @posts = @topic.get_posts
        @post_id = id
        @posts.each {|post|
           post.properties ||= {}
           post.properties['author'] = @facade.get_user( post.created_by )
           post.properties['body'] = @facade.get_message( post.body_id )
        }
        @post = Post.new
        post = @facade.get_post( id.to_i )
        msg = @facade.get_message( post.body_id )
        @body = "[quote=#{post.created_by} @ #{post.created}]" +
                 msg.body +
                "[/quote]"

        @scripts << "editcode.js" << "editextra.js"
        @title = "reply to @{@topic.title}"
        render :edit
     end
     def post id
        @facade.add_post(@input.t_id.to_i, @input.postbody || "empty post")
        @facade.commit

        redirect "/topic/#{@input.t_id}"
     end
  end
   class NewCategory < R '/newcategory'
      def get
         return redirect "/login" if @user.group != 'admin'
         @title = "new category"
         render :new_category
      end
      def post
         category = Category.new
         category.title = @input.title
         category.description = @input.description
         category.created_by = @user.login
         @facade.persist category
         board = @facade.get_board
         board.add_category category
         @facade.commit

         redirect "#{app_root}/board"
      end
   end
   class NewForum < R '/newforum'
      def get
         return redirect "#{app_root}/login" if @user.group != 'admin'
         @categories = @facade.get_board.get_categories
         @title = "new forum"
         render :new_forum
      end
      def post
         category = @facade.get_category @input.c_id.to_i
         forum = Forum.new
         forum.title = @input.title
         forum.description = @input.description
         forum.created_by = @user.login
         @facade.persist forum
         category.add_forum forum
         @facade.commit
        
         redirect "#{app_root}/board"
      end
   end
   class RepairLastPosted < R '/repair_last_posted'
      def get
         @board = @facade.get_board
         @facade.begin_tx
         @board.categories.each do | category |
            category.forums.each do | forum |
               forum.topics.each do |topic |
                  topic.update_last_post( @facade.get_last_post_for_topic topic.get_id )
               end if forum.topics
            end 
         end
         @facade.commit
      end
   end
         
   # NB Only intended for testing. Note hard coded forum ID !
   class BulkAddPosts < R '/bulk_add_posts'
      def get
         if !@facade.is_admin
            return redirect "/login"
         end
         @topics = 0
         @posts = 0
         @lines = []
         forum = @facade.get_forum(111) # 'Introduction'
         File.open( 'lib/Introductions-posts.txt' ) do |f|
            puts "processing file #{f.path}"
            begin
               loop  do
                  s = f.readline
                  puts "read line <#{s}>"
                  if s =~ /^Topic: /
             #        puts "read topic line <#{s}>"
                     @t = Topic.new
                     attribs = /Topic: (.*?), desc: (.*?), id: (.*?), posted: (.*?), by: (.*?), on: (.*?)$/.match( s )
                     @t.title =attribs[1][0,32]
                     @t.description = attribs[2]
                     @t.properties = HashMap.new
                     @t.properties["bcrb-oid"] = attribs[3]
                     @t.created = Time.parse attribs[6]
                     @t.created_by = attribs[5]
                     @facade.persist(@t)
                     @forum.add_topic( @t )
                     @topics += 1
                  elsif s =~ /^Post: /
             #        puts "read post line <#{s}>"
                     @p = Post.new
                     attribs = /Post: (.*?), user: (.*?), posted: (.*?), topic: (.*?), body: $/.match( s )
                     oids = /f=(\d*?)&t=(\d*?)&p=(\d*?)$/.match(attribs[1])
                     @p.created = Time.parse attribs[3]
                     @p.created_by = attribs[2]
                     @p.properties = HashMap.new
                     @p.properties["bcrb-oid"] = oids[3]

                     @posts += 1
                  else
                     @lines << s
                     if s =~ /»$/
                        puts "adding post #{@posts} for topic #{@topics}..."
                        @m = Message.new
                        body = @lines.join('').gsub(/[«»]/, '')
                        @m.body = body.to_s
                        @m.created_by = @p.created_by
                        @m.created = @p.created

                        @facade.persist @m
                        @facade.flush

                        @p.body_id = @m.get_id
                        @facade.persist @p
                        @t.add_post( @p )
                        @lines = []
                     end
                  end
              end
            rescue
               puts "Rescue: #{$!}"
               puts "EOF: #{@topics} topics and #{@posts} posts"
            end
            @facade.commit
            
            redirect "/board"
         end
      end
   end
  # bulk add users -- remove
  class BulkAddNewUsers < R '/new_users'
     def get
        if !@facade.is_admin
           return redirect "/login"
        end
        @facade.add_new_users
        redirect "/members"
     end
  end

  class Snoop < R '/snoop'
    def get
      @member ||= @facade.getUser( 'admin' )
      
      @login_name = @member.name
      session = env['java.servlet_request'].session true
      @message ||= "Session['message']: #{session['message']}"
      
      @snoop = {}
      @snoop[:env] = env
      @snoop[:load_path] = $LOAD_PATH
      render :snoop
    end
  end

=begin
    class CStatic < R '/static/(.+)'
        def get(path)
            @headers['Content-Type'] = Board::MIME_TYPES[path[/\.\w+$/, 0]] || "text/plain"
            @headers['X-Sendfile'] = File.join(Board::STATIC_PATH, path)
        end
    end
=end
   class Style < R '/styles.css'
       def get
           @headers["Content-Type"] = "text/css; charset=utf-8"
           @body = %{
                body {background-color: #ffc;}
           }
       end
   end

end
