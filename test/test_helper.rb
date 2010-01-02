$:.unshift File.join( File.dirname(File.dirname(__FILE__)), "lib" )

require "pepper"

require "rubygems"

require "test/unit"
require "shoulda"
require "rr"
require "time"

class Test::Unit::TestCase
  include RR::Adapters::TestUnit
  
  def response(name)
    Pepper::Stanzas::Epp.parse File.read( File.join(File.dirname(__FILE__),"fixtures", "#{name}.xml") )
  end
end