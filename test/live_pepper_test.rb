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
  
  context "command" do
    setup do
      @hash = YAML.load_file( File.join(File.dirname(__FILE__), "live_settings.yaml" ))
      Pepper.settings = @hash
    end
    
    context "'check'" do
      should "return available for 'foo.co.uk'" do
        assert_equal( {"foo.co.uk" => true}, Pepper.check( 'foo.co.uk' ))
      end
      
      should "return correct hash for 'foo.co.uk', 'bar.co.uk' and 'macduff-TAG.co.uk'" do
        domains = {"foo.co.uk" => true, "bar.co.uk" => true, "macduff-#{@hash[:tag]}.co.uk" => false}
        assert_equal domains, Pepper.check( *domains.keys )
      end
    end
    
    context "'info'" do
      should "return correct hash for 'adriana-TAG.co.uk'" do
        # We cannot predict exactly when it was created at
        info       = Pepper.info( "adriana-#{@hash[:tag]}.co.uk" )
        created_at = Time.xmlschema(info["cr_date"])
        
        expected = {
          "reg_status" => "Registered until expiry date.",
          "name"       => "adriana-#{@hash[:tag].downcase}.co.uk",
          "cr_id"      => "psamathe@nominet.org.uk",
          "first_bill" => "th",
          "recur_bill" => "th",
          "cl_id"      => @hash[:tag],
          "ex_date"    => (created_at + 2 * 60*60*24*365).strftime("%FT%T"), # 2 years
          "cr_date"    => created_at.strftime("%FT%T"),
          "account"    => {
            "trad_name"  => "Simple Registrant Trading Ltd",
            "name"       => "Simple Registrant-#{@hash[:tag]}",
            "cr_id"      => "psamathe@nominet.org.uk",
            "cl_id"      => @hash[:tag],
            "type"       => "LTD",
            "opt_out"    => "N",
            "roid"       => "105097-UK",
            "cr_date"    => (created_at + 1 * 60*60*24*365).strftime("%FT%T"), # 1 year
            "contacts"   => [{
              "name"       => "Mary Smith",
              "up_id"      => "psamathe@nominet.org.uk",
              "cl_id"      => @hash[:tag],
              "roid"       => "C112040-UK",
              "phone"      => "01234 567890",
              "up_date"    => (created_at + 1 * 60*60*24*365).strftime("%FT%T"), # 1 year
              "email"      => "mary.smith@ariel-#{@hash[:tag].downcase}.co.uk"
            }],
            "addr"       => {
              "city"       => "Test City",
              "country"    => "GB",
              "postcode"   => "TE57 1NG",
              "street"     => [ "2 Test Street" ],
              "county"     => "Testshire"
            }
          },
          "ns"         => {
            "hosts"      => [{
              "hostname"   => "ns1.ariel-#{@hash[:tag].downcase}.co.uk."
            }]
          }
        }
        
        assert_equal( expected, Pepper.info( "adriana-#{@hash[:tag]}.co.uk" ))
      end
    end
    
    context "'create'" do
      should "register a domain" do
        expected = {
          "result"      => { "msg" => "Command completed successfully" },
          "resdata"     => { },
          "result_code" => "1000"
        }
        options = {
          "name"    => "#{Time.now.to_i}-testingdomain-#{@hash[:tag]}.co.uk",
          "account" => {
            "name"     => "Foo Bar",
            "type"     => "LTD",
            "co_no"    => "NI123456",
            "opt_out"  => "N",
            "addr"     => {
              "street"   => "1 Test",
              "locality" => "Testville",
              "city"     => "Test",
              "county"   => "Testshire",
              "postcode" => "TE57 7ES",
              "country"  => "GB"
            },
            "contacts" => [{
              "name"     => "Joe Test",
              "phone"    => "01234 567890",
              "email"    => "joe@test.com"
            }]
          }
        }
        assert_equal( expected, Pepper.create( options ) )
      end
    end
  end

end