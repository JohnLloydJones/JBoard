require './lib/board'
run Rack::Adapter::Camping.new(Board)
