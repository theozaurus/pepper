$:.unshift File.dirname(__FILE__)
require "test_helper"

class LivePepperTest < Test::Unit::TestCase
  
  context "logging in with correct credentials" do
    setup do
      Pepper.settings = YAML.load_file( File.join(File.dirname(__FILE__), "live_settings.yaml" ))
    end
    
    should "return true" do
      assert_equal true, Pepper.login
    end
    
    context "twice" do
      should "return true" do
        assert_equal true, Pepper.login
        assert_equal true, Pepper.login
      end
    end
  end

  context "logging in with incorrect credentials" do
    should "raise error" do
      Pepper.settings = YAML.load_file( File.join(File.dirname(__FILE__), "live_settings.yaml" )).merge( :tag => "FOO" )
      
      assert_raises Pepper::Error::Security do
        Pepper.login
      end
    end
  end

end