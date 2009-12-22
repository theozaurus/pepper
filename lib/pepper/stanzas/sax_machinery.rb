require "sax-machine"

# Mixup the mixin - to add functionality for simplifying results down to a hash
module SAXMachine
  def to_hash
    convert = Proc.new {|v| 
      if v.methods.include? "to_hash"
        v.to_hash
      elsif v.is_a? Array
        v.map {|e| convert.call e }
      else
        v
      end
    }
    
    instance_variables.inject({}) do |h,v|
      h.merge v.gsub("@","") => convert.call( instance_variable_get v )
    end
  end
end