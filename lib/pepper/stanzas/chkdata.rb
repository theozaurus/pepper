require "pepper/stanzas/sax_machinery"

module Pepper
  module Stanzas
    class Chkdata
      include SAXMachine
      
      elements "domain:name", :as => :domain_names
      elements "domain:name", :as => :domain_names_avail, :value => :avail

    end
  end
end