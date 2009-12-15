module Pepper
  module Stanzas
    class Resdata
      include SAXMachine
        
      element "domain:chkData", :as => :chkdata, :class => Chkdata
    end
  end
end