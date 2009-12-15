$:.unshift File.dirname(__FILE__)
require "test_helper"

class LivePepperTest < Test::Unit::TestCase
  
  def setup
    Pepper.settings = YAML.load_file( File.join(File.dirname(__FILE__), "live_settings.yaml" ))
  end
    
  context "logging in with correct credentials" do
    should "return true" do
      assert_equal true, Pepper.login
    end
  end

end