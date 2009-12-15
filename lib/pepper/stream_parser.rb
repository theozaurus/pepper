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
    end
            
    def start_element name, attrs = []
      @start = name unless @start
    end

    def end_element name
      @end = true if @start == name
    end
    
  end
end