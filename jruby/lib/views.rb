require 'rubygems'
require 'lib/bbcode'
require 'lib/encrypt'
require 'lib/sendmail'


module Board
   module Views
      include ::BBCode
      def layout
         xhtml_transitional do
            link :rel=>"shortcut icon", :href=>"#{app_root}/images/favicon.ico", :type=>"image/x-icon"
            title "#{@title} :: #{board_properties['board_name']}"
            style  :type => 'text/css' do
               @styles.each do |f|
                  self << "@import '#{app_root}/styles/#{f}';"
               end if @styles
            end
            @scripts.each do |f|
               script :type=>"text/javascript", :src=>"/scripts/#{f}"
            end if @scripts
   #      link :rel => 'stylesheet', :type => 'text/css',
   #           :href =>  "#{(Board::APP_NAME + '/styles/style.css')}", :media => 'screen'
            body do
               div.content! do
                  div.logostrip! do
                     a :href => "/board", :title => "#{board_properties['board_name']} Home" do
                        img :src => "/images/logo-jboard.png", :alt => 'JBoard'
                     end
                  end 

                  table :width => "100%", :id => "userlinks", :cellspacing => "6" do
                     tr do
                        td  do
                           if @user.state == "unregistered"
                              self << "Welcome #{@user.login} ( "
                              a "Log in", :href=>"/login"
                              self << " | "
                              a "Register", :href=>"/register"
                              self << " )"
                           else
                              self << "Logged in as:  "
                              a @user.login, :href=>"/personal/#{@user.uid}"
                              self << " ( "
                              a "Log out", :href=>"/logout"
                              self << " )"
                           end
                        end
                        td :align=>"right" do
                           if %w{moderated registered}.include? @user.state
                              a :href=>"/members", :title=>"View Members" do
                                 img :src=>"/images/members.png"
                                 strong " Members"
                              end
                           else
                              self << "&nbsp;"
                           end
                           
                        end
                     end
                  end

                  self << yield

                  form.quick :action=>"/login", :method=>"post" do
                     div :align=>"right" do
                        strong "Quick Log In: "
                        input :name=>"referrer", :value=>"#{@req_url}", :type=>"hidden"
                        input.forminput :size=>"10",  :type=>"text", :name=>"login", :onfocus=>"this.value=''", :value=>"User Name"
                        input.forminput :size=>"10",  :type=>"password", :name=>"password",
                              :onfocus=>"this.value=''", :value=>" ~secret~ "
                        input.forminput :value=>"Go", :type=>"submit"
                     end
                  end
                  div.copyright :align=>"center" do
                     br
                     self << "JBoard v#{board_properties['board_version']}-Beta © 2009. &nbsp;Released under an MIT License."
                  end
               end
            end
         end
      end

      # TODO: Remove this as it is no longer used ()
      def index
         h2 "Board Home"
      #  p "Camping says: #{@message}"
      # p "Admin's name is #{admin.name} and his email is #{admin.email}"
         p { a 'Snoop', :href => R(Snoop) }
     end

      def login
         br
         self << "You must already have registered for an account before you can log in."
         br
         self << "If you do not have an account, please "
         a "Register", :href=>"/register"
         self << ". It's quick and easy."
         br
         br
         b do
            self << "I've forgotten my password!"
            a "Reset my password", :href=>"/reset_password"
         end
         br
         br
         form.user_login! :method => 'post', :class => 'create', :onsubmit=>"return validateLogin();" do
            input :name=>"referer", :value=>"", :type=>"hidden"
   
            div.tableborder do
               div.maintitle do
                 img :src=>"images/nav_m.png", :alt=>"<"
                 self << " Log In"
               end
               div.pformstrip "Please enter your details below to log in"
               errors_for @user if @user
               table.tablebasic :cellspacing=>"1" do
                  tr do
                     td.pformleft do
                        strong "Enter your name"
                        br
                        self << "This is the name you chose when you registered"
                     end
                     td.pformright do
                        input.login! :type => 'text'
                     end
                  end
                  tr do
                     td.pformleft do
                        strong 'Enter your Password'
                     end
                     td.pformright do
                        input.password! :type => 'password'
                     end
                  end
               end
               div.pformstrip :align=>"center" do
                  input.login_btn! :type => 'submit', :value => "Login"
               end
            end
         end
      end
=begin   
   # TODO: complete this
   def nav_strip *a
      div.breadcrumb! :align=>"left" do
         img :src=>"images/nav.png", :alt=>"&gt;"
         a "Board Home", :href=>"/board"
         if a[0].exists? do
            self <<   "&nbsp;-&gt;&nbsp;"
            a a[0], :href=>"/forum"
         end
      end
   end
=end   
      
   def board_settings
      form.user_register! :method=>"post", :onsubmit=>"return validateSettings();" do
         div.tableborder do
            div.maintitle :align=>'left' do
               img :src=>"images/nav_m.png", :alt => ">"
               a "Board Settings", :href=>self/""
            end

            errors_for @user if @user
            table :width=>"100%", :border=>"0", :cellpadding=>"4", :cellspacing=>"1" do
               tr do
                 th.titlemedium "Please fill out the settings carefully ", :colspan=>"2"
               end
               tr do
                  td.pformleft do
                     strong "Please enter the mail host"
                     br
                     self << "This is the smtp server that emails will be sent to"
                  end
                  td.pformright do
                  input.forminput :type=>"text", :size=>"32", :maxlength=>"255", :value=>"#{@board.properties['smtp_host']}", :name=>"smtp_host"
                  end
               end
               tr do
                  td.pformleft do
                     strong "Please enter the smtp user name:"
                     br
                     self << "This is the user name at your smtp server. Leave blank if your smtp server doesn't require login."
                  end
                  td.pformright do
                  input.forminput :type=>"text", :size=>"32", :maxlength=>"64", :value=>"#{@board.properties['smtp_user']}", :name=>"smtp_user"
                  end
               end
               tr do
                  td.pformleft do
                     strong "Please enter the password:"
                     br
                     self << "This is the password for the smtp user. Leave blank if your smtp server doesn't require login."
                  end
                  td.pformright do
                  input.forminput :type=>"password", :size=>"32", :maxlength=>"64", :value=>" ~secret~ ", :name=>"smtp_password"
                  end
               end
               tr do
                  td.pformleft do
                     strong "Please enter the security question:"
                     br
                     self << "Users who register will be asked to answer this question."
                  end
                  td.pformright do
                  input.forminput :type=>"text", :size=>"32", :maxlength=>"255", :value=>"#{@board.properties['reg_question']}", :name=>"reg_question"
                  end
               end
               tr do
                  td.pformleft do
                     strong "Please enter the answer to the security question:"
                     br
                     self << "This is the answer to the security question. Regular expressions are allowed."
                  end
                  td.pformright do
                  input.forminput :type=>"text", :size=>"32", :maxlength=>"255", :value=>"#{@board.properties['reg_answer']}", :name=>"reg_answer"
                  end
               end
            end
            div.pformstrip :align=>"center" do
              input.forminput :value=>"Submit", :type=>"submit", :name=>"submit"
            end
         end         
      end
   end
   def register
      form.user_register! :method=>"post", :onsubmit=>"return validateRegForm();" do
         div.tableborder do
            div.maintitle :align=>'left' do
              img :src=>"images/nav_m.png", :alt => ">"
              a "Registration Form", :href=>self/""
            end

            errors_for @user if @user
            table :width=>"100%", :border=>"0", :cellpadding=>"4", :cellspacing=>"1" do
               tr do
                 th.titlemedium "Please fill out the form completely ", :colspan=>"2"
               end
               tr do
                  td.pformleft do
                     strong "Please choose a user name"
                     br
                     self << "Usernames must be between 3 and 32 characters long; spaces are allowed"
                  end
                  td.pformright do
                  input.forminput :type=>"text", :size=>"32", :maxlength=>"32", :value=>"", :name=>"username", :id=>"username"
                  end
               end
               tr do
                  td.pformleft do
                     strong "Please choose a password"
                     br
                     self << "Passwords must be between 3 and 32 characters long"
                  end
                  td.pformright do
                  input.forminput :type=>"password", :size=>"32", :maxlength=>"32", :value=>"", :name=>"password", :id=>"password"
                  end
               end
               tr do
                  td.pformleft do
                     strong "Please retype your password"
                     br
                     self << "It must match exactly."
                  end
                  td.pformright do
                  input.forminput :type=>"password", :size=>"32", :maxlength=>"32", :value=>"", :name=>"password_check", :id=>"password_check"
                  end
               end
               tr do
                  td.pformleft do
                     strong "Please enter your email address"
                     br
                     self << "It must be a valid, working email address."
                  end
                    td.pformright do
                    input.forminput :type=>"text", :size=>"32", :maxlength=>"32", :value=>"", :name=>"useremail", :id=>"useremail"
                  end
               end
            end
         end

          div.tableborder do
             div.pformstrip do
                 self << "Security Question"
              end
              table.tablebasic do
                tr do
                  td.row1 :width=>"40%" do
                      strong "To help reduce spammers"
                      br
                      self << @board.properties['reg_question']
                  end
                  td.row1 :width=>"60%" do
                      input.forminput :type=>"text", :size=>"32", :maxlength=>"32", :name=>"reg_quest"
                  end
                end
              end
          end

          div.tableborder do
             div.pformstrip do
                self << "Terms of service"
            end
             div.tablepad :align=>"center" do
                 strong "Please read fully and check the 'I agree' box ONLY if you agree with the terms."
                 br
                 textarea.textinput :cols=>"80", :rows=>"9", :readonly=>"readonly", :name=>"terms" do
                    self << board_properties['reg_terms']
                 end
                 br
                 br
                 label "I agree", :for=>"agree"
                 self << " "
                 input.agree! :name=>"agree", :value=>"1", :type=>"checkbox"

              end
              div.pformstrip :align=>"center" do
                input.forminput :value=>"Submit my registration", :type=>"submit", :name=>"submit"
              end
           end
       end #form
     end
     def members
        div.breadcrumb! :align=>"left" do
           img :src=>"#{app_root}/images/nav.png", :alt=>"&gt;"
           self << "&nbsp;"
           a "Board Home", :href=>"#{app_root}/board"
           self << "&nbsp;-&gt;&nbsp;Members"
        end
        self << 'Not complete'

        div.tableborder do
           div.maintitle :align=>'left', :id=>"" do
              img :src=>"#{app_root}/images/nav_m.png", :alt => ">"
              self << "Member List"
           end

           table :width=>"100%", :border=>"0", :cellpadding=>"4", :cellspacing=>"1" do
               tr do
                 th.titlemedium "Name", :align=>"center"
                 th.titlemedium "Group", :align=>"left"
                 th.titlemedium "Joined", :align=>"center"
                 th.titlemedium "Posts", :align=>"center"
                 th.titlemedium "Email", :align=>"center"
               end
               @members.each do |member|
                  tr do
                    td.row4 do
                       strong do
                          a member.name, :href=>"#{app_root}/personal/#{member.get_id}"
                       end
                    end
                    td.row4 member.group
                    td.row4 member.created
                    td.row4 member.properties['num_posts']
                    td.row4 do
                       img :src=>"#{app_root}/images/p_email.png", :alt=>'Email'
                    end
                  end
              end
           end
        end
     end
     
     def personal
        div.breadcrumb! :align=>"left" do
           img :src=>"/images/nav.png", :alt=>"&gt;"
           self << "&nbsp;"
           a "Board Home", :href=>"/board"
           self << "&nbsp;-&gt;&nbsp;Personal page of "
           span "#{@member.name}"
        end
        
        
        div.tableborder do
           div.maintitle :align=>"left" do
              img :src=>"/images/nav_m.png", :alt=>"&gt;"
              self << "&nbsp;#{@member.name}'s Personal Page"
           end
        end
        
        div :class=>"colmask threecol" do
           div.colmid do
              div.colleft do
                 div.col1 do
#                    <!-- Column 1 start -->
                    div.c1head do
                       div :class=>"title-stuff" do
                          "Use this page to keep up to date with what's happening " +
                                        "and to keep in touch with your friends."
                       end
                    end
                    div do
                       div :class=>"short-message" do
                          form :method=>"post", :onsubmit=>"return submitMessage()" do
                             a :name=>"share" do
                                img :src=>"/images/quote.png"
                                starter_txt = @user.validated? ? "Type what's on your mind here..." : "Login to share what's on your mind."
                                textarea.forminput starter_txt, :name=>"short-message",
                                   :id=>"short-message", :rows=>"2",
                                   :onfocus=>"clickedMsg()", :onclick=>"clickedMsg()", :onblur=>"onblurMsg ()"
                             end
                             div :class=>"msg-type" do
                                select.forminput :onchange=>"changeMsgType()", :id=>"msg-sel", :name=>"type" do
                                   option "Public", :value=>"public"
                                   option "Private", :value=>"private"
                                end
                                span.private! :style=>"display: none;" do
                                   self << "&nbsp;For:&nbsp;"
                                   input.forminput :type=>"text", :name=>"recipient", :id=>"msg-to", :size=>"12"
                                end
                             end
                             div :class=>"button-right" do
                                if @user.validated?
                                   input.forminput :type=>"submit", :value=>"Share", :id=>"msg-submit"
                                else
                                  input.forminput :type=>"button", :value=>"Share", :id=>"msg-submit",:disabled=>'disabled'
                                end
                             end
                          end
                       end
                       
                       div.happening do
                          h3 "What's been happening?"
                          @events.each do |event|
                             div.event do
                                if %w{moderated registered}.include? event.properties['author_state']
                                   a :href=>"/personal/#{event.properties['author_id']}" do
                                      strong "#{event.created_by}"
                                   end
                                else
                                   strong "#{event.created_by}"
                                end
                                if event.type == "post"
                                   self << " Posted: "
                                   a "Reply", :href=>"/topic/#{event.properties['topic_id']}?#p#{event.properties['post_id']}"
                                   self << " to: "
                                   em "#{event.properties['topic_title']}"
                                   br
                                   self << "#{event.created}"
                                else
                                   self << " Said: #{event.created}"
                                   blockquote do
                                      self << "#{event.properties['body'].bbcode_to_html}"
                                      if event.text =~ /^friend request/
                                         input :type=>'button', :value=>'Accept',:src=>'/images/accept.png', :onclick=>"acceptFriend('#{event.get_id}')"
                                         input :type=>'button', :value=>'Reject',:src=>'/images/reject.png', :onclick=>"rejectFriend('#{event.get_id}')"
                                      end
                                   end
                                end
                             end
                          end
                       end
                    # <!-- Column 1 end -->
                    end
                 end
                 div.col2 do
                    div do
        # <!-- Column 2 start -->
                       table.member do
                          tr do
                             td.avatar do
                                img :src=>"#{@member.avatar || "/images/generic-avatar-1.png"}", :width=>"125"
                             end
                             td.details do
                                input.user_id! :type=>'hidden', :value=>"#{@member.get_id}"
                                ul.user do
                                   li { strong "#{@member.name.capitalize}" }
                                   li "Joined: #{@member.created}"
                                   li "Posts: #{@member.properties['num_posts']}"
                                   li do
                                      state = @member.state
                                      if @user.group == 'admin'
                                         select.forminput :id=>"user_state", :onchange=>"changeUserState()" do
                                            %w{validating moderated registered privileged}.each do |val|
                                               if val == state
                                                  option val.capitalize, :value=>val, :selected=>"selected"
                                               else
                                                  option val.capitalize, :value=>val
                                               end
                                            end
                                         end
                                      else
                                         self << state
                                      end
                                   end
                                end
                             end
                          end
                       end
                       h3 "Board Quick Links"
                       @board.categories.each do |cat|
                          div.category do
                             a "#{cat.title}", :href=>"#{app_root}/category/#{cat.get_id}"
                          end
                          ul.forums do
                             cat.forums.each do |forum|
                                li do
                                   a "#{forum.title}", :href=>"#{app_root}/forum/#{forum.get_id}"
                                end
                             end
                          end
                       end
                    end
#        <!-- Column 2 end -->
                 end
                 div.col3 do
#        <!-- Column 3 start -->
                    if @user.uid == @member.get_id 
                       div.feature do
                          h3 "Profile"
                       end
                       ul :class=>"feature-list" do
                          if %w{moderated registered}.include? @user.state
                             li { a "#{@user.login}", :href=>"/profile/#{@user.uid}", :title=>"Edit my profile" }
                          else
                             li "#{@user.login} (log in to view)"
                          end
                       end
                    end
                    if @user.group == 'admin' 
                       div.feature do
                          h3 "Admin tasks"
                       end
                       ul :class=>"feature-list" do
                          li { a "Board Settings", :href=>"/board_settings", :title=>"Edit board settings" }
                       end
                    end
                    
                    div.feature do
                       h3 do
                          img :src=>"#{app_root}/images/members.png"
                          self << "&nbsp;Friends"
                       end
                    end
                    ul :class=>"feature-list" do
                       @member.friends.each do |friend|
                          li { a "#{friend.name}", :href=>"/personal/#{friend.get_id}", :title=>"#{friend.name}'s personal page" }
                       end
                    end
                    if @user.uid == @member.get_id 
                       div.commands :id=>'friend-cmds' do
                          a :href=>"#", :title=>"Add new friends", :onclick=>"addFriend()" do
                             img :src=>"/images/user.png"
                             self << "&nbsp;add"
                          end
                          self << "&nbsp;"
                          a :href=>"#", :title=>"Remove a friend", :onclick=>"removeFriend()" do
                             img :src=>"/images/delete-user.png"
                             self << "&nbsp;remove"
                          end
                       end
                    end
                    div.feature do
                       h3 "Places"
                    end
                    
                    if ! @member.links.empty?
                       ul :class=>"feature-list" do
                          @member.links.each do |link|
                             li do 
                                a "#{link.text}", :href=>"#{link.url}", :id=>"oid-#{link.get_id}", :target=>"_blank"
                                br
                                em "#{link.description}"
                             end
                          end
                       end
                    end
                    if @user.uid == @member.get_id 
                       div.commands :id=>'place-cmds' do
                          a :href=>"#", :onclick=>"addPlace()", :title=>"Add new places" do
                             self << "&nbsp;add"
                          end
                          a :href=>"#", :onclick=>"removePlace()", :title=>"Remove place" do
                             self << "&nbsp;remove"
                          end
                       end
                    end
#        <!-- Column 3 end -->
                 end
              end       
           end
        end
       
        div.footer! do
           div.darkrow2 { self << "&nbsp;" }
        end
     end
     def profile
        self << "not completed yet"

        div.tableborder do
           table.basic :cellspacing=>2, :cellpadding=>0, :width=>'100%' do
               tr do
                  th.maintitle "Profile for #{member.name}", :colspan=>2
               end
               tr do
                  td.row3 :width=>"30%" do
                     strong "Name"
                  end
                  td.row1 :width=>"70%" do
                     @member.name
                  end
               end
               tr do
                  td.row3 do
                     strong "Given Name"
                  end
                  td.row1 do
                     @member.first
                  end
               end

               tr do
                  td.row3 do
                     strong "Group"
                  end
                  td.row1 do
                     @member.group
                  end
               end
               tr do
                  td.row3 do
                     strong "Status"
                  end
                  td.row1 do
                     @member.state
                  end
               end
               tr do
                  td.row3 do
                     strong "Joined"
                  end
                  td.row1 do
                     @member.created
                  end
               end
               tr do
                  td.row3 do
                     strong "Password"
                  end
                  td.row1 do
                     input.forminput :type=>"password", :value=>"nonsense", :readonly=>'readonly'
                     self << "&nbsp;"
                     input.forminput :type=>"button", :value=>"Change", :onclick=>"changePassword(this)"
                  end
               end
               tr do
                  td.row3 do
                     strong "Avatar"
                  end
                  td.row1 do
                     input.avatar! :type=>'hidden', :value=>@member.avatar
                     if member.avatar
                        img :src=>"#{member.avatar}"
                     else
                        em "(none)"
                     end
                     br
                     input.forminput :type=>"button", :value=>"Change", :onclick=>"changeAvatar(this)"
                  end
               end
               tr do
                  td.row3 do
                     strong "Signature"
                  end
                  td.row1 do
                     input.sig! :type=>'hidden', :value=>@member.sig
                     self << @member.sig.bbcode_to_html if @member.sig
                     br
                     input.forminput :type=>"button", :value=>"Change", :onclick=>"changeSignature(this)"
                  end
               end
               tr do
                  td.row3 do
                     strong "Photo"
                  end
                  td.row1 do
                     if member.photo
                        img :src=>"#{member.photo}"
                     else
                        em "(none)"
                     end
                  end
               end

           end
           div.pformstrip :align=>"center" do
              self << "&lt;( "
              a "back", :href=>"javascript:history.go(-1)"
              self << " )"
           end

        end
     end
     
     def render_category category
        div.tableborder do
           div.maintitle :align=>'left' do
#           p.expand :onclick=>"togglecategory(29, 1);", :align=>'right' do
#             img :src=> "images/exp_minus.png", :title => "Collapse this category", :alt=> 'Collapse'
#           end
              img :src=>"#{app_root}/images/nav_m.png", :alt => ">"
              a category.title, :href=>"#{app_root}/category/#{category.get_id}"
           end
           table :width=>"100%", :border=>"0", :cellpadding=>"4", :cellspacing=>"1" do
              tr do
                 th.titlemedium " ", :align=>"center", :width=>"2%"
                 th.titlemedium "Forum", :align=>"left", :width=>"59%"
                 th.titlemedium "Topics", :align=>"center", :width=>"7%"
                 th.titlemedium "Replies", :align=>"center", :width=>"7%"
                 th.titlemedium "Last Post Info", :align=>"left", :width=>"25%"
              end
              category.forums.each do |forum|
                 last_posted_topic = forum.properties['last_posted_topic']
                 last_posted_topic_id = forum.properties['last_posted_topic_id']
                 num_posts = forum.properties['last_posted_topic_num_posts'] || 1;
                 if last_posted_topic.nil? || last_posted_topic.last_post_date.nil?
                    last_date = '--'
                    last_title = '---'
                    num_replies = '0'
                    last_author = ''
                    last_post_page = 1
                 else
                    last_date = last_posted_topic.last_post_date || ''
                    last_title = last_posted_topic.title || ''
                    num_replies = last_posted_topic.num_replies
                    last_author = last_posted_topic.last_post_author || ''
                    last_post_page = (num_posts + 14) / 15
                 end
                 tr do
                    td.row4 :align=>"center" do
                       img :src=> 'images/nonew.png'
                    end
                    td.row4 :align=>"left" do
                       strong do
                          a forum.title, :href => "/forum/#{forum.get_id.to_s}"
                       end
                       br
                       span.desc forum.description
                    end
                    td.row2 forum.topics.size, :align=>"center"
                    td.row2  num_replies.to_s, :align=>"center"
                    td.row2 :align=>"left" do
                       self << last_date
                       br
                       self << 'In: '
                       a last_title, :href => "/topic/#{last_posted_topic_id.to_s}?p=#{last_post_page}#p#{last_posted_topic_id.to_s}"
                       br
                       self << 'By: ' + last_author
                    end
                 end
              end
              tr do
                 td.darkrow2  :colspan=>"5" do
                    self << "&nbsp;"
                    pp = category.pending_posts || []
                    if pp.size > 0 && (@user.group == 'admin' || category.moderator?( @user.login ))
                       self << "There are #{pp.size} post(s) pending approval:&nbsp;"
                       a "Review Now", :href=>"/pending/#{category.get_id}"
                    end
                    if @user.group == 'admin'
                       input :type=>'hidden', :id=>"mods_#{category.get_id}", :name=>'old_mods', :value=>"#{category.moderators.join('|')}"
                       input :type=>'hidden', :id=>"cat_#{category.get_id}", :name=>'category', :value=>"#{category.get_id}" 
                       self << "&nbsp;"
                       a :href=>"#", :onclick=>"return manageModerators(this)" do
                          img  :src=>"/images/c_mods.png", :alt=>"Manage Moderators"
                       end
                       self << "&nbsp;(#{category.moderators.join(',')})"
                    else
                      self << "&nbsp;Led by: #{category.moderators.join(',')}" if !category.moderators.empty?
                    end
                 end
              end
           end
        end
     end
     def board
        div.breadcrumb! :align=>"left" do
           img :src=>"images/nav.png", :alt=>"&gt;"
           self << "&nbsp;Board Home"
        end
        if 'admin' == @user.group
           table :cellpadding=>"0", :cellspacing=>"0", :width=>"100%" do
              tr do
                 td :align=>"left", :width=>"20%" do
                    self << " "
                 end
                 td :align=>"right", :width=>"80%" do
                    a :href=>"#{app_root}/newcategory", :title=>"Add New Category" do
                       img  :src=>"#{app_root}/images/c_new.png", :alt=>"New Category"
                    end
                 end
                 td :align=>"right", :width=>"80%" do
                    a :href=>"#{app_root}/newforum", :title=>"Add New Forum" do
                       img  :src=>"#{app_root}/images/f_new.png", :alt=>"New Forum"
                    end
                 end
              end
           end
        end
        @board.categories.each do |category|
           render_category category
        end
     end
     def category
        div.breadcrumb! :align=>"left" do
           img :src=>"/images/nav.png", :alt=>"&gt;"
           self << "&nbsp;"
           a "Board Home", :href=>"#{app_root}/board"
           self << "&nbsp;-&gt;&nbsp;#{@category.title}"
        end
        render_category @category
     end
     def pending
        @pending.each do |post|
           div.tableborder do
              topic = post.properties['topic']
              div.maintitle :align=>'left' do
                 img :src=>'/images/nav_m.png', :alt => ">"
                 a "In topic: #{topic.title}", :href=>"/topic/#{topic.get_id}"
              end
              div do
                 a :href=>"/approve_post/#{post.get_id}", :title=>"Approve this post" do
                    img :src=>"/images/p_accept.png", :alt=>"Accept"
                 end
                 self << "&nbsp;"
                 a :href=>"/reject_post/#{post.get_id}", :title=>"Reject this post" do
                    img :src=>"/images/p_reject.png", :alt=>"Reject"
                 end
              end
              render_post post
           end
        end
        redirect "/pending/#{@category.get_id}"
     end
     def forum
        div.breadcrumb! :align=>"left" do
           img :src=>"/images/nav.png", :alt=>"&gt;"
           self << "&nbsp;"
           a "Board Home", :href=>"#{app_root}/board"
           self << "&nbsp;-&gt;&nbsp;"
           a "#{@category.title}", :href=>"#{app_root}/category/#{@category.get_id}"
           self << "&nbsp;-&gt;&nbsp;#{@forum.title}"
        end
        
        table :cellpadding=>"0", :cellspacing=>"0", :width=>"100%" do
           tr do
              td :align=>"left", :width=>"20%" do
                 self << "Pages: (#{@num_pages})"
                 @num_pages.times do |n|
                    if @page.to_i == n+1
                       b "[#{n+1}]"
                    else
                       a "#{n+1}", :href=>"/forum/#{@forum.get_id}?p=#{n+1}"
                    end
                 end
              end
              if %w{moderated registered}.include? @user.state
                 td :align=>"right", :width=>"80%" do
                    a :href=>"#{app_root}/newtopic/#{@forum.get_id}" do
                       img  :src=>"../images/t_new.png", :alt=>"Add New Topic"
                    end
                 end
              end
           end
        end
       div.tableborder do
          div.maintitle :align=>'left' do
   #           p.expand :onclick=>"togglecategory(29, 1);", :align=>'right' do
   #             img :src=> "images/exp_minus.png", :title => "Collapse this category", :alt=> 'Collapse'
   #           end
              img :src=>"#{app_root}/images/nav_m.png", :alt => ">"
             a @forum.title, :href=>"#{app_root}/forum/#{@forum.get_id}"
           end
           table :width=>"100%", :border=>"0", :cellpadding=>"4", :cellspacing=>"1" do
              tr do
                 th.titlemedium " ", :align=>"center"
                 th.titlemedium "Topic Title", :align=>"left"
                 th.titlemedium "Topic Starter", :align=>"center"
                 th.titlemedium "Replies", :align=>"center"
                 th.titlemedium "Last Action", :align=>"left"
              end
              @topics.each do |topic|
                 tr do
                    if topic.locked?
                       td.row2 :width=>"32" do img :src=>'../images/locked.png', :alt=>'Locked' end
                    else
                       td.row2 " "
                    end
                    td.row2  :align=>"left" do
                       strong { a topic.title, :href=>"#{app_root}/topic/#{topic.get_id}" }
                       br
                       span.desc "#{topic.description}"
                    end
                    td.row2 topic.created_by, :align=>"center"
                    td.row2 topic.num_replies, :align=>"center"
                    td.row2 :align=>"left" do
                       self << topic.last_post_date
                       br
                       a 'Last Post By: ', :href=>"#{app_root}/topic/#{topic.get_id}#p#{topic.last_post_id}"
                       self << topic.last_post_author
                    end
                 end
              end
              tr do
                 td.darkrow2  :colspan=>"5" do
                    self << "&nbsp;"
                 end
              end
           end
        end
     end

     def topic
        div.breadcrumb! :align=>"left" do
           img :src=>"#{app_root}/images/nav.png", :alt=>"&gt;"
           self << "&nbsp;"
           a "Board Home", :href=>"#{app_root}/board"
           self << "&nbsp;-&gt;&nbsp;"
           a "#{@category.title}", :href=>"#{app_root}/category/#{@category.get_id}"
           self << "&nbsp;-&gt;&nbsp;"
           a "#{@forum.title}", :href=>"#{app_root}/forum/#{@forum.get_id}"
        end
        table :cellpadding=>"0", :cellspacing=>"0", :width=>"100%" do
           tr do
              td :align=>"left", :width=>"20%" do
                 self << "Pages: (#{@num_pages})"
                 @num_pages.times do |n|
                    if @page.to_i == n+1
                       b "[#{n+1}]"
                    else
                       a "#{n+1}", :href=>"#{app_root}/topic/#{@topic.get_id}?p=#{n+1}"
                    end
                 end
              end
              if %w{moderated registered}.include? @user.state
                 td :align=>"right", :width=>"80%" do
                    if @user.group == 'admin' || @category.isModerator( @user.login )
                       a :href=>"/delete_topic/#{@topic.get_id}", :title=>"Delete this topic" do
                          img  :src=>"../images/t_delete.png", :alt=>"Delete Topic"
                       end
                       self << "&nbsp;"
                    end
                    if ! @topic.locked? || @user.group == 'admin'
                       a :href=>"/newpost/#{@topic.get_id}", :title=>"Reply to this topic" do
                          img  :src=>"../images/t_reply.png", :alt=>"Add Reply"
                       end
                       self << "&nbsp;"
                    end
                    a :href=>"/newtopic/#{@forum.get_id}", :title=>"Start a new topic" do
                       img  :src=>"../images/t_new.png", :alt=>"Add New Topic"
                    end
                 end
              end
           end
        end
        br
       div.tableborder do
         div.maintitle :align=>'left' do
   #           p.expand :onclick=>"togglecategory(29, 1);", :align=>'right' do
   #             img :src=> "images/exp_minus.png", :title => "Collapse this category", :alt=> 'Collapse'
   #           end
             img :src=>'../images/nav_m.png', :alt => ">"
             a @topic.title, :href=>"/topic/#{@topic.get_id}"
             self << ",&nbsp;#{@topic.description}" if @topic.description

         end
       input :type=>'hidden', :value=>"#{app_root}/topic/#{@topic.get_id}?p=#{@page}", :id=>"page_url", :name=>"page_url"
       @posts.each do |post|
          render_post post
       end
     end
    end
     
   def render_post post
       table :width=>"100%", :border=>"0", :cellpadding=>"4", :cellspacing=>"1" do
          tr.row4 do
            td :align=>"left" do
               a :name=>"p#{post.get_id}"
               if @user.validated && %w{moderated registered}.include?( post.properties['author'].state )
                  a "#{post.properties['author'].name}", :href=>"#{app_root}/personal/#{post.properties['author'].get_id}"
               else
                  self << post.created_by
               end
            end
            td :align=>"left" do
              div.posted :align=>'left' do
                 span.postdetails "Posted: #{post.created }"
              end
              if @user.validated?
                div :align=>'right' do
                   input :type=>'hidden', :value=>"#{post.get_id}", :id=>"p#{post.get_id}", :name=>"p_id"
                   a :href=>"#", :onclick=>"return reportPost(this)"  do
                      img :src=>'/images/p_report.png', :alt=>'Report Post'
                   end
                   if (@user.group == 'admin' || @category.moderator?( @user.login ))
                      a :href=>"/delete_post/#{post.get_id}" do
                         img :src=>'/images/p_delete.png', :alt=>'Delete Post'
                      end
                   end
                   if post.created_by == @user.login || 'admin' == @user.group
                     a :href=>"/edit/#{post.get_id}" do
                         img :src=>'/images/p_edit.png', :alt=>'Edit Post'
                     end
                   end
                   a :href=>"#{app_root}/quote/#{post.get_id}" do
                      img :src=>'../images/p_quote.png', :alt=>'Quote Post'
                   end
                end
              end
            end
          end
          tr.post2 do
            td.postauthor :width=>"13%" do
               img :src=>post.properties['author'].avatar || '/images/generic-avatar-1.png'
               br
               span.postdetails "Group: #{post.properties['author'].group}"
               br
               span.postdetails "Posts: #{post.properties['num_posts']}"
               br
               span.postdetails "Joined: #{post.properties['author'].created}"
            end
            td.postbody :width=>"87%" do
               self << post.properties['body'].body.bbcode_to_html
               if post.properties['author'].sig
                  br
                  br
                  hr :width=> "16%", :align=>"left"
                  div.signature do
                     self << post.properties['author'].sig.bbcode_to_html
                  end
               end
            end
          end
          tr do
             td.darkrow3 :align=>'left' do
                span.desc @user.group == 'admin' ? "IP: [ #{@user_ip} ]" : " "
             end
             td.darkrow3 :align=>'left' do
                div.contacts do
                   if %w{moderated registered}.include? @user.state
                      a :href=>"/personal/#{post.properties['author'].get_id}", :title=>'Show user\'s personal page' do
                         img :src=>'../images/addresscard.png', :alt=>'Personal Page'
                      end
                      a :href=>"#", :title=>'PM Poster', :onclick=>"return pmUser(this, '#{post.properties['author'].name}')" do
                         img :src=>'../images/p_pm.png'
                      end
=begin                      
                      a :href=>"email/#{post.properties['author'].name}", :title=>'Email Poster' do
                         img :src=>'../images/p_email.png'
                      end
=end                      
                   end
                end
                div.darkrow3 :align=>'right' do
                   a :href=>'javascript:scroll(0,0)' do
                      img :src=>'../images/p_up.png', :alt=>'Top'
                   end
                end
             end
          end
       end
     end
     def edit
       div.tableborder do
         div.maintitle :align=>'left' do
            self << (@topic ? "Replying to #{@topic.title}" : "Post a New Topic in #{@forum.title}")
         end
         form :name=>'REPLIER', :method=>'post', :onsubmit=>'return ValidateForm()' do
           table :width=>"100%", :border=>"0", :cellpadding=>"4", :cellspacing=>"1" do
               if @topic.nil?
                  tr do
                     td.pformstrip "Topic Settings", :colspan=>"2"
                  end
                  tr do
                     td.pformleft "Topic Title"
                     td.pformright do
                        input.forminput :type=>"text", :size=>"40", :maxlength=>"32", :name=>"topic_title", :tabindex=>"1"
                     end
                  end
                  tr do
                     td.pformleft "Topic Description"
                     td.pformright do
                        input.forminput :type=>"text", :size=>"40", :maxlength=>"128", :name=>"topic_desc", :tabindex=>"2"
                     end
                  end
               end
               tr do
                 td.pformstrip "Code Buttons", :colspan=>"2"
               end
               tr do
                 td.pformleft do
                   input :type=>'hidden', :name=>'bbmode', :value=>'normal'
                   input :type=>'hidden', :name=>'bbmode', :value=>'normal'
                   input :type=>'hidden', :name=>'f_id', :value=>"#{@forum.get_id}" if @forum
                   input :type=>'hidden', :name=>'t_id', :value=>"#{@topic.get_id}" if @topic
                   input :type=>'hidden', :name=>'p_id', :value=>"#{@post_id}"
                   self << " "
                 end
                 td.pformright do
                   input.codebuttons :type=>'button', :value=>' B ', :onclick=>'simpletag("B");', :name=>'B', :style=>'font-weight:600', :onmouseover=>'hstat("bold")'
                   input.codebuttons :type=>'button', :value=>' I ', :onclick=>'simpletag("I");', :name=>'I', :style=>'font-style:italic', :onmouseover=>'hstat("italic")'
                   input.codebuttons :type=>'button', :value=>' U ', :onclick=>'simpletag("U");', :name=>'U', :style=>'text-decoration: underline', :onmouseover=>'hstat("underline")'
                   input.codebuttons :type=>'button', :value=>' HLIGHT ', :onclick=>'simpletag("HLIGHT");', :name=>'HLIGHT',  :onmouseover=>'hstat("hlight")'

                   select.codebuttons :name=>'ffont', :onchange=>"alterfont(this.options[this.selectedIndex].value, 'FONT')",  :onmouseover=>'hstat("font")' do
                     option 'FONT ',   :value=>'0'
                     option 'Arial',   :value=>'Arial',   :style=>'font-family:Arial'
                     option 'Times ',  :value=>'Times',   :style=>'font-family:Times'
                     option 'Courier', :value=>'Courier', :style=>'font-family:Courier'
                     option 'Impact',  :value=>'Impact',  :style=>'font-family:Impact'
                     option 'Geneva',  :value=>'Geneva',  :style=>'font-family:Geneva'
                     option 'Optima',  :value=>'Optima',  :style=>'font-family:Optima'
                   end
                   select.codebuttons :name=>'fsize', :onchange=>"alterfont(this.options[this.selectedIndex].value, 'SIZE')",  :onmouseover=>'hstat("size")' do
                     option "SIZE",    :value=>'0'
                     option "Small",   :value=>'1'
                     option "Large",   :value=>'7'
                     option "Largest", :value=>'14'
                   end
                   select.codebuttons :name=>'fcolor', :onchange=>"alterfont(this.options[this.selectedIndex].value, 'COLOR')",  :onmouseover=>'hstat("color")' do
                     option "COLOR",    :value=>'0'
                     option "Blue",   :value=>'Blue'
                     option "Green", :value=>'Green'
                     option "Grey", :value=>'grey'
                     option "Orange", :value=>'orange'
                     option "Purple", :value=>'purple'
                     option "Red",   :value=>'red'
                     option "Yellow", :value=>'yellow'
                   end

                   self << '&nbsp;'
                   a "Close all Tags", :href=>'javascript:closeall();', :onmouseover=>"hstat('close')"
                   br
                   input.codebuttons :type=>'button', :accesskey=>'h', :value=>' http:// ', :onclick=>'tag_url()', :name=>'url', :onmouseover=>"hstat('url')"

                   input.codebuttons :type=>'button', :accesskey=>'g', :value=>' IMG ', :onclick=>'tag_image()', :name=>'img', :onmouseover=>"hstat('img')"
                   input.codebuttons :type=>'button', :accesskey=>'e', :value=>'  @  ', :onclick=>'tag_email()', :name=>'email', :onmouseover=>"hstat('email')"
                   input.codebuttons :type=>'button', :accesskey=>'q', :value=>' QUOTE ', :onclick=>'simpletag("QUOTE")', :name=>'QUOTE', :onmouseover=>"hstat('quote')"
                   input.codebuttons :type=>'button', :accesskey=>'p', :value=>' CODE ', :onclick=>'simpletag("CODE")', :name=>'CODE', :onmouseover=>"hstat('code')"
                   input.codebuttons :type=>'button', :accesskey=>'l', :value=>' LIST ', :onclick=>'tag_list()', :name=>"LIST",  :onmouseover=>"hstat('list')"
           br
           input.row1 "Open Tags: ", :type=>'text', :name=>'tagcount', :size=>'3', :maxlength=>'3', :style=>'font-size:10px;font-family:verdana,arial;border:0px;font-weight:bold;', :readonly=>"readonly", :value=>"0"
           self << "&nbsp;"
           input.row1 :type=>'text', :name=>'helpbox', :size=>'50', :maxlength=>'120', :style=>'width:auto;font-size:10px;font-family:verdana,arial;border:0px', :readonly=>"readonly", :value=>"Hint: Use Guided Mode for helpful prompts"

                 end
             end
             tr do
                 td.pformstrip "Enter Post", :colspan=>"2"
             end
             tr do
                 td.pformleft do
                   self << " "
                 end
                 td.pformright do
                   textarea.textinput :cols=>'80', :rows=>'20', :name=>'postbody', :tabindex=>'3' do
                       self << @body if @body
                   end
                 end
             end
             tr do
                 td.pformstrip :align=>'center', :style=>'text-align:center', :colspan=>"2"
                   input :type=>"submit", :name=>"submit", :value=>"Add Reply", :tabindex=>'4', :accesskey=>'s'
=begin                   
                   self << '&nbsp;'
                   input :type=>"submit", :name=>"preview", :value=>"Preview Post", :tabindex=>'5'
=end                   
             end
           end
         end
        end
     end
     def new_category
        form :method=>'post' do
           div.tableborder do
              div.maintitle "Add a new category"
              self << "This page allows you to add a new category to your board."
              br;br
              div.maintitle "All fields are required"
              table :width=>'100%', :cellspacing=>'0', :cellpadding=>'5' do
                 tr do
                    td.row1  :width=>'30%', :valign=>'middle' do
                        strong "Category Name"
                    end
                    td.tdrow2 :width=>'60%', :valign=>'middle' do
                       input.textinput :type=>'text', :name=>'title', :value=>'', :size=>'32', :maxlength=>"32"
                    end
                 end
                 tr do
                    td.row1  :width=>'30%', :valign=>'middle' do
                        strong "Category Description"
                    end
                    td.tdrow2 :width=>'60%', :valign=>'middle' do
                       input.textinput :type=>'text', :name=>'description', :value=>'', :size=>'32', :maxlength=>"128"
                    end
                 end

                 tr do
                    td.pformstrip :align=>'center', :colspan=>'2' do
                       input.textinput :type=>'submit', :value=>'Create', :id=>'button', :accesskey=>'s'
                    end
                 end
              end
           end
        end
     end
     def new_forum
        form :method=>'post' do
           div.tableborder do
              div.maintitle "Add a new forum"
              self << "This page allows you to add a new forum to your board."
              br;br
              div.maintitle "All fields are required"
              table :width=>'100%', :cellspacing=>'0', :cellpadding=>'5' do
                 tr do
                    td.row1  :width=>'30%', :valign=>'middle' do
                        strong "Category Name"
                        br
                        self << "Choose the category in which you want to create a new forum."
                    end
                    td.tdrow2 :width=>'60%', :valign=>'middle' do
                       select.textinput :name=>'c_id' do
                          @categories.each do |category|
                             option "#{category.title}", :value=>"#{category.get_id}"
                          end
                       end
                    end
                 end
                 
                 tr do
                    td.row1  :width=>'30%', :valign=>'middle' do
                        strong "Forum Name"
                    end
                    td.tdrow2 :width=>'60%', :valign=>'middle' do
                       input.textinput :type=>'text', :name=>'title', :value=>'', :size=>'32', :maxlength=>"32"
                    end
                 end
                 tr do
                    td.row1  :width=>'30%', :valign=>'middle' do
                        strong "Forum Description"
                    end
                    td.tdrow2 :width=>'60%', :valign=>'middle' do
                       input.textinput :type=>'text', :name=>'description', :value=>'', :size=>'32', :maxlength=>"128"
                    end
                 end

                 tr do
                    td.pformstrip :align=>'center', :colspan=>'2' do
                       input.textinput :type=>'submit', :value=>'Create', :id=>'button', :accesskey=>'s'
                    end
                 end
              end
           end
        end
     end
     def not_found
        div.breadcrumb! :align=>"left" do
           img :src=>"/images/nav.png", :alt=>"&gt;"
           self << "&nbsp;"
           a "Board Home", :href=>"/board"
           self << "&nbsp;-&gt;&nbsp;Page Not Found"
        end
        br
        br
        div.tableborder do
           div.maintitle "Oops, there was a problem with the page you requested."
           table :width=>'100%', :cellspacing=>'0', :cellpadding=>'5' do
              tr do
                 td.pformleft  :width=>'30%', :valign=>'middle' do
                     strong "Message:"
                 end
                 td.pformright do
                    self << "#{@not_found_msg}"
                 end
              end
              tr do
                 td.pformleft  :width=>'30%', :valign=>'middle' do
                     strong "Further information:"
                 end
                 td.pformright do
                    self << "If you entered the page address by hand, please check that you typed it correctly. "
                    br
                    a "Board home", :href=>"/board"
                 end
              end
           end
           div.pformstrip :align=>"center" do
              self << "&lt;( "
              a "back", :href=>"javascript:history.go(-1)"
              self << " )"
           end
        end
     end
     
      def dl_hash(hash)
        dl {
          hash.keys.each do |k|
            dt { text(k.to_s.humanize + "&nbsp;"); tt {k.to_s}}
            dd {
              if Hash === hash[k]
                dl_hash(hash[k])
              elsif Array === hash[k]
                ul { hash[k].each {|v| li { v.to_s }} }
              else
                text("  " + hash[k].to_s + "\n")
              end
            }
          end
        }
 
      end
     def snoop
       h2 "Snoop"
       div { "Request URL: #{@req_url}"}
       div { "#{"http" + URL("/").to_s }, @root is #{@root}, self/'/' is #{self/'/'} " }

       div { dl_hash(@snoop) }
       p { a 'Home', :href => self/"." }
     end

   end
end
