$:.unshift File.join( File.dirname(File.dirname(__FILE__)), "lib" )

require "pepper"

require "rubygems"

require "test/unit"
require "shoulda"
require "rr"
require 'stringio'

class Test::Unit::TestCase
  include RR::Adapters::TestUnit
end