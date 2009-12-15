require "nokogiri"

module Pepper
  class StreamParser < Nokogiri::XML::SAX::Document
        
    def initialize(stream)
      @stream = stream
    end
    
    def get_frame
      @parser = Nokogiri::XML::SAX::PushParser.new self
      @data   = ""
      @start, @end = nil
      header = @stream.read(4)
      begin
        d = @stream.read(1)
        @data   << d # Nasty: Duplicates data to feed into sax machine, done because sax-machine does not use a push parser
        @parser << d # This parser is used to find the end of the stanza in the stream
      end until @end
      @stanza = Pepper::Stanzas::Epp.parse @data
      parse_response_code @stanza.response unless @stanza.greeting
      @stanza
    end
            
    def start_element name, attrs = []
      @start = name unless @start
    end

    def end_element name
      @end = true if @start == name
    end
    
  private
    
    def parse_response_code(response)
      code = response.result_code
      msg  = response.result.msg.strip
      case code[0].chr
      when "1"
        # Positive completion reply
      when "2"
        # Negative completion reply
        case code[1].chr
        when "0" : raise Error::ProtocolSyntax.new msg
        when "1" : raise Error::ImplentationSpecificRules.new msg
        when "2" : raise Error::Security.new msg
        when "3" : raise Error::DataManagement.new msg
        when "4" : raise Error::ServerSystem.new msg
        when "5" : raise Error::ConnectionManagement.new msg
        else
          raise Error::UnrecognisedResponse.new msg
        end
      else
        raise Error::UnrecognisedResponse.new msg  
      end
    end
    
  end
end