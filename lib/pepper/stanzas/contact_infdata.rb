require "pepper/stanzas/sax_machinery"

module Pepper
  module Stanzas
    class ContactInfdata
      include SAXMachine
      
      element "contact:roid",   :as => :roid
      element "contact:name",   :as => :name
      element "contact:phone",  :as => :phone
      element "contact:email",  :as => :email
      
      element "contact:clID",   :as => :cl_id
      element "contact:crID",   :as => :cr_id
      element "contact:crDate", :as => :cr_date
      element "contact:upID",   :as => :up_id
      element "contact:upDate", :as => :up_date
      
    end
  end
end