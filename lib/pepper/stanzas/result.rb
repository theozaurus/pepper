module Pepper
  module Stanzas
    class Result
      include SAXMachine
      
      element :msg
    end
  end
end