module Pepper
  module Error
    class ProtocolSyntax              < StandardError; end
    class ImplementationSpecificRules < StandardError; end
    class Security                    < StandardError; end
    class DataManagement              < StandardError; end
    class ServerSystem                < StandardError; end
    class ConnectionManagement        < StandardError; end
    
    class UnrecognisedResponse        < StandardError; end    
  end
end