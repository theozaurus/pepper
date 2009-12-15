require "rubygems"
gem "sax-machine"

require "pepper/stanzas"
require "pepper/connection"
require "pepper/commands"
require "pepper/stream_parser"

Pepper.class_eval do
  include Pepper::Connection
  include Pepper::Commands
end