require "socket"
require "openssl"

module Pepper
  module Connection
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      attr_accessor :connection
      
      def settings=(opts = {})
        @server   = opts[:server]
        @tag      = opts[:tag]
        @password = opts[:password]
        @port     = opts[:port] || 700
        @lang     = opts[:lang] || "en"
        
        @logged_in = false
        @parser    = nil
      end
      
      def connect
        sock                    = TCPSocket.new( @server, @port )
        ssl_context             = OpenSSL::SSL::SSLContext.new
        ssl_context.verify_mode = OpenSSL::SSL::VERIFY_NONE
        self.connection         = OpenSSL::SSL::SSLSocket.new( sock, ssl_context )
        
        self.connection.sync_close
        self.connection.connect
        
        @parser = StreamParser.new self.connection
        @parser.get_frame
        
        self.connection
      end
      
      def write(xml)
        (@parser && self.connection || self.connect).write(xml)
        @parser.get_frame
      end
    end
    
  end
end