require "pepper/stanzas/sax_machinery"
require "pepper/stanzas/chkdata"
require "pepper/stanzas/domain_data"

module Pepper
  module Stanzas
    class Resdata
      include SAXMachine
        
      element "domain:chkData", :as => :chkdata, :class => Chkdata
      element "domain:creData", :as => :credata, :class => DomainData
      element "domain:infData", :as => :infdata, :class => DomainData
    end
  end
end