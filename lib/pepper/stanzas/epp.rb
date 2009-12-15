module Pepper
  module Stanzas
    class Epp
      include SAXMachine
      
      element :response, :class => Response
    end
  end
end