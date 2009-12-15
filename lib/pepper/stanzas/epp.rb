module Pepper
  module Stanzas
    class Epp
      include SAXMachine
      
      element :greeting
      element :response, :class => Response
    end
  end
end