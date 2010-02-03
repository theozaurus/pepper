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
          "reg_status" => info["reg_status"],
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
            "roid"       => info["account"]["roid"],
            "cr_date"    => (created_at + 1 * 60*60*24*365).strftime("%FT%T"), # 1 year
            "contacts"   => [{
              "name"       => "Mary Smith",
              "up_id"      => "psamathe@nominet.org.uk",
              "cl_id"      => @hash[:tag],
              "roid"       => info["account"]["contacts"][0]["roid"],
              "phone"      => "01234 567890",
              "up_date"    => (created_at + 1 * 60*60*24*365).strftime("%FT%T"), # 1 year
              "email"      => "mary.smith@ariel-#{@hash[:tag]}.co.uk"
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
        expected["up_date"] = info["up_date"] if info["up_date"]
        expected["up_id"]   = info["up_id"] if info["up_id"]
        
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
    
    context "'update'" do
      should "support adding and removing nameservers" do
        #http://www.nominet.org.uk/registrars/systems/nominetepp/testbed/
        options = {
          "name"       => "adriana-#{@hash[:tag].downcase}.co.uk",
          "ns"         => {
            "hosts"      => [
              {"hostname"   => "ns1.ariel-#{@hash[:tag].downcase}.co.uk."},
              {"hostname"   => "ns1.demetrius-#{@hash[:tag].downcase}.co.uk."} # this one is getting added
            ]
          }
        }
        Pepper.update( options )
        assert_equal options["ns"]["hosts"].map{|e| e["hostname"]}, Pepper.info( "adriana-#{@hash[:tag]}.co.uk" )["ns"]["hosts"].map{|e| e["hostname"]}
        
        options = {
          "name"       => "adriana-#{@hash[:tag].downcase}.co.uk",
          "ns"         => {
            "hosts"      => [
              {"hostname"   => "ns1.ariel-#{@hash[:tag].downcase}.co.uk."},
            ]
          }
        }
        Pepper.update( options )
        assert_equal options["ns"]["hosts"].map{|e| e["hostname"]}, Pepper.info( "adriana-#{@hash[:tag]}.co.uk" )["ns"]["hosts"].map{|e| e["hostname"]}
      end

      should "support adding and removing trad-name" do
        existing_settings = Pepper.info("demetrius-#{@hash[:tag]}.co.uk")
        
        options = {}
        options["name"]    = existing_settings["name"]
        options["account"] = existing_settings["account"]
        options["account"]["trad_name"] = "12345"
        options["account"].delete("contacts")
        
        Pepper.update( options )
        assert_equal options["account"]["trad_name"], Pepper.info( "demetrius-#{@hash[:tag]}.co.uk" )["account"]["trad_name"]
        
        options["account"].delete("trad_name")
        Pepper.update( options )
        
        assert !Pepper.info( "demetrius-#{@hash[:tag]}.co.uk" )["account"].has_key?("trad_name")
      end

      should "support adding and removing a contact" do
        existing_settings = Pepper.info("demetrius-#{@hash[:tag]}.co.uk")
        
        new_contact = { "name" => "Foobar", "email" => "foo@bar.com", "phone" => "1235" }
        
        options = {}
        options["name"]    = existing_settings["name"]
        options["account"] = existing_settings["account"]
        options["account"]["contacts"] << new_contact
        
        Pepper.update(options)
        interested_fields = %w(name phone email)
        assert_equal options["account"]["contacts"].map{|c| c.reject{|k,v| !interested_fields.include? k}},
                     Pepper.info("demetrius-#{@hash[:tag]}.co.uk")["account"]["contacts"].map{|c| c.reject{|k,v| !interested_fields.include? k}}
        
        options["account"]["contacts"].pop
        
        Pepper.update(options)
        assert_equal options["account"]["contacts"].map{|c| c.reject{|k,v| !interested_fields.include? k}},
                     Pepper.info("demetrius-#{@hash[:tag]}.co.uk")["account"]["contacts"].map{|c| c.reject{|k,v| !interested_fields.include? k}}
      end
      
      should "support adding a phone number to a contact" do
        existing_settings = Pepper.info("demetrius-#{@hash[:tag]}.co.uk")
                
        options = {}
        options["name"]    = existing_settings["name"]
        options["account"] = existing_settings["account"]
        options["account"]["contacts"][0]["phone"] = "07711 111111"
        
        Pepper.update(options)
        interested_fields = %w(name phone email)
        assert_equal options["account"]["contacts"].map{|c| c.reject{|k,v| !interested_fields.include? k}}, 
                     Pepper.info("demetrius-#{@hash[:tag]}.co.uk")["account"]["contacts"].map{|c| c.reject{|k,v| !interested_fields.include? k}}
        
        options["account"]["contacts"][0].delete("phone")
        
        Pepper.update(options)
        assert_equal options["account"]["contacts"].map{|c| c.reject{|k,v| !interested_fields.include? k}}, 
                     Pepper.info("demetrius-#{@hash[:tag]}.co.uk")["account"]["contacts"].map{|c| c.reject{|k,v| !interested_fields.include? k}}
      end
      
      should "support adding and removing a second street line" do
        existing_settings = Pepper.info("demetrius-#{@hash[:tag]}.co.uk")
                
        options = {}
        options["name"]    = existing_settings["name"]
        options["account"] = existing_settings["account"]
        options["account"]["addr"]["street"] = ["second floor", "foo street"]
        
        Pepper.update(options)
        assert_equal options["account"]["addr"], Pepper.info("demetrius-#{@hash[:tag]}.co.uk")["account"]["addr"]
        
        options["account"]["addr"]["street"] = ["foo street"]
        
        Pepper.update(options)
        assert_equal options["account"]["addr"], Pepper.info("demetrius-#{@hash[:tag]}.co.uk")["account"]["addr"]
      end
    end
  end

end