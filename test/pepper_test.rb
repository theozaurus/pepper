$:.unshift File.dirname(__FILE__)
require "test_helper"

class PepperTest < Test::Unit::TestCase
  context "logging in" do
    should "write login stanza" do
      mock( Pepper ).write(anything) { response "login_success" }
      Pepper.login
    end
  end
end