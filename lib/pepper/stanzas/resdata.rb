require "pepper/stanzas/sax_machinery"
require "pepper/stanzas/chkdata"
require "pepper/stanzas/domain_infdata"

module Pepper
  module Stanzas
    class Resdata
      include SAXMachine
        
      element "domain:chkData", :as => :chkdata, :class => Chkdata
      element "domain:infData", :as => :infdata, :class => DomainInfdata
    end
  end
end