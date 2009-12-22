require "pepper/stanzas/sax_machinery"
require "pepper/stanzas/account_addr"
require "pepper/stanzas/contact_infdata"

module Pepper
  module Stanzas
    class AccountInfdata
      include SAXMachine
      
      element  "account:roid",       :as => :roid
      element  "account:name",       :as => :name
      element  "account:trad-name",  :as => :trad_name
      element  "account:type",       :as => :type
      element  "account:co-no",      :as => :co_no
      element  "account:opt-out",    :as => :opt_out
      element  "account:addr",       :as => :addr,     :class => AccountAddr
            
      element  "account:clID",       :as => :cl_id
      element  "account:crID",       :as => :cr_id
      element  "account:crDate",     :as => :cr_date
      element  "account:upID",       :as => :up_id
      element  "account:upDate",     :as => :up_date
      
      elements "contact:infData",    :as => :contacts, :class => ContactInfdata
    end
  end
end