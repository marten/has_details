module HasDetails
  def self.included(base)
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
  end
  
  module ClassMethods
    def has_details(options = {})
      configuration = { }
      configuration.update(options) if options.is_a?(Hash)
      
      raise(ArgumentError, "You must be supply at least one field in the configuration hash") unless configuration.keys.size > 0
      raise(Exception, "A details column must be present in the database for this plugin.") unless columns.include?(:details)
      
      serialize :details, Hash
      
      configuration.each do |f,t|

        exception_code = t.is_a?(Array) ? "raise \"Assigned value must be one of #{t.inspect}\" unless #{t.inspect}.include?(val)" : \
                                          "raise \"Assigned value must be a #{t.inspect}\" unless val.is_a?(#{t.inspect})"
        
        puts <<-EOV
          def #{f}
            @details[:#{f}]
          end
          
          def #{f}=(val)
            #{exception_code}
            @details[:#{f}] = val
          end
        EOV
      end
      
    end
  end
  
  module InstanceMethods
    
  end
  
end