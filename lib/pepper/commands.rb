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
              }
            }
          end
          r = self.write( builder.to_xml )
        end
        @logged_in = true
      end
      
      def check(*domains)
        login unless @logged_in
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.epp("xmlns"              => "urn:ietf:params:xml:ns:epp-1.0", 
                  "xmlns:xsi"          => "http://www.w3.org/2001/XMLSchema-instance",
                  "xsi:schemaLocation" => "urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd" ) {
            xml.command {
              xml.check {
                xml.check("xmlns:domain"       => "http://www.nominet.org.uk/epp/xml/nom-domain-2.0",
                          "xsi:schemaLocation" => "http://www.nominet.org.uk/epp/xml/nom-domain-2.0 nom-domain-2.0.xsd") {
                  xml.parent.namespace = xml.parent.namespace_definitions.first
                  domains.each {|d|
                    xml["domain"].name d
                  }
                }
              }
            }
          }
        end
        r = self.write( builder.to_xml )
        r.response.resdata.chkdata.domain_names.inject({}){|hash,domain|
          hash.merge( domain => r.response.resdata.chkdata.domain_names_avail.shift == "1")
        }
      end
      
      def info(name)
        login unless @logged_in
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.epp("xmlns"              => "urn:ietf:params:xml:ns:epp-1.0", 
                  "xmlns:xsi"          => "http://www.w3.org/2001/XMLSchema-instance",
                  "xsi:schemaLocation" => "urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd" ) {
            xml.command {
              xml.info {
                xml.info("xmlns:domain"       => "http://www.nominet.org.uk/epp/xml/nom-domain-2.0",
                         "xsi:schemaLocation" => "urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd") {
                  xml.parent.namespace = xml.parent.namespace_definitions.first
                  xml["domain"].name name
                }
              }
            }
          }
        end
        r = self.write( builder.to_xml )
        r.response.resdata.infdata.to_hash
      end
    end
  end
end