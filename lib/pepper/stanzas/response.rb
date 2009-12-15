module Pepper
  module Stanzas
    class Response
      include SAXMachine
      
      element :result, :class => Result
      element :result, :as => :result_code, :value => :code
      element :resData, :as => :resdata, :class => Resdata
    end
  end
end