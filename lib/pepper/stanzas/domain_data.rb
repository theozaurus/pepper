require "pepper/stanzas/sax_machinery"
require "pepper/stanzas/account_infdata"
require "pepper/stanzas/ns"

module Pepper
  module Stanzas
    class DomainData
      include SAXMachine
      
      element "domain:name",               :as => :name
      element "domain:reg-status",         :as => :reg_status
      element "account:infData",           :as => :account,   :class => AccountInfdata
      element "domain:ns",                 :as => :ns,        :class => Ns
      element "domain:reg-status",         :as => :reg_status
      element "domain:clID",               :as => :cl_id
      element "domain:crID",               :as => :cr_id
      element "domain:crDate",             :as => :cr_date
      element "domain:upID",               :as => :up_id
      element "domain:upDate",             :as => :up_date
      element "domain:exDate",             :as => :ex_date
                                           
      element "domain:first-bill",         :as => :first_bill
      element "domain:recur-bill",         :as => :recur_bill
      element "domain:auto-bill",          :as => :auto_bill
      element "domain:next-bill",          :as => :next_bill
      element "domain:notes",              :as => :notes
      element "domain:renew-not-required", :as => :renew_not_required
      element "domain:reseller",           :as => :reseller
    end
  end
end