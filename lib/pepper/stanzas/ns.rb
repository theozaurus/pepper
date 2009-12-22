require "pepper/stanzas/sax_machinery"
require "pepper/stanzas/host"

module Pepper
  module Stanzas
    class Ns
      include SAXMachine
      
      elements "domain:host", :as => :hosts, :class => Host

    end
  end
end