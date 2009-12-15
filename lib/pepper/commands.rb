module Pepper
  module Commands
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      # http://www.nominet.org.uk/registrars/systems/nominetepp/login/
      def login
        unless @logged_in
          builder = Nokogiri::XML::Builder.new do |xml|
            xml.epp("xmlns"              => "urn:ietf:params:xml:ns:epp-1.0", 
                    "xmlns:xsi"          => "http://www.w3.org/2001/XMLSchema-instance",
                    "xsi:schemaLocation" => "urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd" ) {
              xml.command {
                xml.login {
                  xml.clID @tag
                  xml.pw   @password
                  xml.options {
                    xml.version "1.0"
                    xml.lang    "en"
                  }
                  xml.svcs {
                    xml.objURI "http://www.nominet.org.uk/epp/xml/nom-domain-2.0"
                  }
                }
                xml.clTRID "ABC-12345"
              }
            }
          end
          r = self.write( builder.to_xml )
          raise Pepper::Error::Login.new r.response.result.msg.strip unless r.response.result_code == "1000"
        end
        @logged_in = true
      end
    end
  end
end