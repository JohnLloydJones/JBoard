
require 'rubygems'
require 'rack'
require 'rack/handler/grizzly'
require 'jruby/rack/grizzly_helper'

require 'lib/board'
require 'lib/adapter'

app = proc do |env|
   env['board.session'] = GlassfishAdapter::get_session( env )
   Rack::Adapter::Camping.new( Board ).call( env )
end
