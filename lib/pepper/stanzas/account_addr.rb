require "pepper/stanzas/sax_machinery"

module Pepper
  module Stanzas
    class AccountAddr
      include SAXMachine
      
      elements "account:street",   :as => :street
      element  "account:locality", :as => :locality
      element  "account:city",     :as => :city
      element  "account:county",   :as => :county
      element  "account:postcode", :as => :postcode
      element  "account:country",  :as => :country
      
    end
  end
end