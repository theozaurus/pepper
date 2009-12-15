module Pepper
  module Stanzas
    class Chkdata
      include SAXMachine
      
      elements "domain:name", :as => :domain_names
      elements "domain:name", :value => :avail, :as => :domain_names_avail

    end
  end
end