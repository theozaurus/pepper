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
      
      def create(opts = {})
        # OPTIMIZE: Break this up - it's way to clunky
        login unless @logged_in
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.epp("xmlns"              => "urn:ietf:params:xml:ns:epp-1.0", 
                  "xmlns:xsi"          => "http://www.w3.org/2001/XMLSchema-instance",
                  "xsi:schemaLocation" => "urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd" ) {
            xml.command {
              xml.create {
                xml.create("xmlns:domain"       => "http://www.nominet.org.uk/epp/xml/nom-domain-2.0",
                           "xsi:schemaLocation" => "http://www.nominet.org.uk/epp/xml/nom-domain-2.0 nom-domain-2.0.xsd") {
                  xml.parent.namespace = xml.parent.namespace_definitions.first
                  xml["domain"].send(:"name",       opts["name"])
                  xml["domain"].send(:"period",     opts["period"])     if opts.has_key? "period"
                  xml["domain"].send(:"first-bill", opts["first_bill"]) if opts.has_key? "first_bill"
                  xml["domain"].send(:"recur-bill", opts["recur_bill"]) if opts.has_key? "recur_bill"
                  xml["domain"].send(:"auto-bill",  opts["auto_bill"])  if opts.has_key? "auto_bill"
                  xml["domain"].send(:"next-bill",  opts["next_bill"])  if opts.has_key? "next_bill"
                  xml["domain"].send(:"notes",      opts["notes"])      if opts.has_key? "notes"
                  xml["domain"].account {
                    xml.create("xmlns:account" => "http://www.nominet.org.uk/epp/xml/nom-account-2.0",
                               "xmlns:contact" => "http://www.nominet.org.uk/epp/xml/nom-contact-2.0"){
                      account = opts["account"]
                      xml.parent.namespace = xml.parent.namespace_definitions.select{|ns| ns.prefix == "account"}.first
                      xml["account"].send(:"name",      account["name"])      if account.has_key? "name"
                      xml["account"].send(:"trad-name", account["trad_name"]) if account.has_key? "trad_name"
                      xml["account"].send(:"type_",     account["type"])      if account.has_key? "type"
                      xml["account"].send(:"co-no",     account["co_no"])     if account.has_key? "co_no"
                      xml["account"].send(:"opt-out",   account["opt_out"])   if account.has_key? "opt_out"
                      xml["account"].addr {
                        addr = account["addr"]
                        Array[*opts["account"]["addr"]["street"]].each{|s| # Allows either a single string passed in or an array to work
                          xml.street s
                        }
                        %w(locality city county postcode country).each {|f|
                          xml.send(f.to_sym, addr[f]) if addr.has_key?(f)
                        }
                      }
                      account["contacts"].each_with_index {|c,i|
                        xml["account"].contact(:order => i+1) {
                          xml["contact"].create {
                            %w(name phone email mobile).each {|f|
                              xml["contact"].send(f.to_sym, c[f]) if c.has_key?(f)
                            }
                          }
                        }
                      }            
                    }
                  }
                  if opts.has_key? "ns"
                    xml["domain"].ns {
                      opts["ns"]["hosts"].each {|host|
                        xml["domain"].host {
                          xml["domain"].hostName               host["hostname"]           if host.has_key? "hostname"
                          xml["domain"].hostAddr(:ip => "v4"){ host["hostaddress_ipv4"] } if host.has_key? "hostaddress_ipv4"
                          xml["domain"].hostAddr(:ip => "v6"){ host["hostaddress_ipv6"] } if host.has_key? "hostaddress_ipv6"
                        }
                      }
                    }
                  end
                }
              }
            }
          }
        end
        r = self.write( builder.to_xml )
        r.response.to_hash
      end
      
    end
  end
end