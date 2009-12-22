require "pepper/stanzas/sax_machinery"

module Pepper
  module Stanzas
    class Host
      include SAXMachine
      
      element "domain:hostName", :as => :hostname
      element "domain:hostAddr", :as => :hostaddress_ipv4, :with => {:ip => "v4"}
      element "domain:hostAddr", :as => :hostaddress_ipv6, :with => {:ip => "v6"}
      
    end
  end
end