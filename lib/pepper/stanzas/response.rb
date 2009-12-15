module Pepper
  module Stanzas
    class Response
      include SAXMachine
      
      element :result, :class => Result
      element :result, :as => :result_code, :value => :code
    end
  end
end