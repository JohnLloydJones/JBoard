# Need to handle the session, because jboard expects an HttpSession object.
# The adapter provides the necessary through the wonders of duck typing.
module GlassfishAdapter
   
   def self.get_session env
      cookies = Camping.kp(env['HTTP_COOKIE'])
      env['rack.url_scheme'] = 'http' # required by rack spec., but not defined by glassfish gem
      
      servlet = GlassfishAdapter::Servlet.new cookies['rsession_id']
      servlet.request_url = "#{env['rack.url_scheme']}://#{env['HTTP_HOST']}#{env['PATH_INFO']}"
      env['java.servlet_request'] = servlet
      env['rsession_id'] = servlet.session_id
      session = servlet.session true    
   end
   
   # Servlet class is a partial replacement for HttpServletRequest. It's main task is to create
   # and maintain the Session object. Only methods required by JBoard are implemented.
   class Servlet
      attr_accessor :request_url
      include MonitorMixin

      # some magic number that are used to build the session id:
      @@MAX_TICKS = 46656 # 36 ^ 3
      @@MOD_LEN = 2176782336 # 36 ^ 6
      
      @@session_count = 0
      @@last_time_val = Time.now.to_i / 2
      
      def initialize id
         super()
         @id = id || generate_id
      end
      
      def session_id
         @id
      end
      
      # Use /dev/urandom; fall back to rand if that fails.
      def get_random
         File.read("/dev/urandom", 8).unpack("H*")[0].hex
      rescue
         rand(9117854927)
      end
      
      # clone of apache SessionIdGenerator
      # format of id is <6 chars random><3 chars time><1+ char count>
      def generate_id
         synchronize do
            n = (get_random() % @@MOD_LEN) + @@MOD_LEN
            time_val = Time.now.to_i
            t = ((time_val / 2) % @@MAX_TICKS) + @@MAX_TICKS
            if time_val != @@last_time_val
               @@session_count = 0
               @@last_time_val = time_val
            end
            @@session_count += 1
            "#{n.to_s(36)[1..-1]}#{t.to_s(36)[1..-1]}#{@@session_count.to_s(36)}"
         end
      end
      
      def session create
         @session = Session.fetch( @id, create )
      end
      
      # Don't know how to get this from Glassfish.
      def remote_addr
         nil
      end
   end
   
   # Session is a replacement for HttpSession. 
   class Session
      attr_accessor :expires
      @@SESSION_TIMEOUT = 1800 # 30 mins in secs
      @@last_tick = Time.now.to_i / 10
      @@store = {}
      
      def initialize id
         @id = id
         @attributes = {}
         @expires = Time.now.to_i + @@SESSION_TIMEOUT
      end
      
      def self.fetch( id, create )
         sweep if @@last_tick != Time.now.to_i / 10
         @@store[id] ||= Session.new( id ) if create
         @@store[id]
      end
      
      def self.sweep
         now = Time.now.to_i
         @@last_tick = now / 10
         @@store.reject! { |k,v| now > v.expires }
      end
      
      def [] key
         @attributes[key]
      end
      
      def []= (key, value)
         @attributes[key] = value
      end

      def get_id
         @id
      end
   end
end
