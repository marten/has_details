module HasDetails
  def self.included(base)
    base.extend(ClassMethods)
  end

  # HasDetails allows you to store a large amount of (optional) attributes for any model's instance in a
  # serialized column. It takes care of adding convenience methods to your model, and verifies that the
  # value being assigned is indeed (one of) the type(s) required for that attribute.
  #
  # Example:
  #
  #   class User << ActiveRecord::Base
  #     has_details :column => :extended_attributes,
  #                 :firstname => String,
  #                 :lastname => String,
  #                 :birthday => Date,
  #                 :gender => [:male, :female]
  #   end
  #
  #   john = User.find(1)
  #   john.birthday = 5.years.ago
  #   john.gender
  #   => :male
  module ClassMethods

    # Configuration options are:
    #
    # * +column+ - Specifies the column name to use for storing the serialized attributes. This column will automatically be set to serialize in Rails. The default value is :details.
    #
    # The rest of the configuration options is the set of attributes that will be saved in the +column+. Valid formats are:
    # * +:field => ClassName+ (values assigned to +field+ must be of class +ClassName+)
    # * +:field => [:symbol, :othersymbol]+  (values assigned to +field+ must be included in the array given)
    def has_details(options = {})
      configuration = {:column => :details}
      configuration.update(options) if options.is_a?(Hash)
      column = configuration[:column]

      raise(ArgumentError, "You must be supply at least one field in the configuration hash") unless configuration.keys.size > 0
#      raise(Exception, "A #{configuration[:column]} column must be present in the database for this plugin.") unless columns.include?(:details)
      
      col = configuration.delete(:column).to_s
      unless serialized_attributes[col]
        serialize col, Hash
      end
      
      configuration.each do |f,t|

        exception_code = if t.is_a?(Array)
          "raise \"Assigned value must be one of #{t.inspect}\" unless #{t.inspect}.include?(val)"
        elsif t == :boolean
          # everything can be converted to boolean so we don't have an exception here
          "val = ActiveRecord::ConnectionAdapters::Column::TRUE_VALUES.include?(val) unless val.nil?"
        elsif t == Integer
          "val = (val.nil? ? nil : (Integer(val) rescue nil))"
        elsif t == BigDecimal
          "val = val.is_a?(BigDecimal) ? val : (val.blank? ? nil : val.to_d)"
        else
          "raise \"Assigned value must be a #{t.inspect}\" unless val.nil? || val.is_a?(#{t.inspect})"
        end
        
        class_eval <<-EOV
          def #{f}
              self.#{column.to_s} ||= {}
              self.#{column.to_s}[:#{f}]
          end

          def #{f}_before_type_cast
            if self.details
              self.details[:#{f}]
            end
          end
          
          def #{f}=(val)
            #{exception_code}

            self.details ||= {}
            if val.nil?#{" || val.blank? " if t == String}
              self.details.delete(:#{f})
            else
              self.details[:#{f}] = val
            end
          end
        EOV

        if t == :boolean
          class_eval <<-EOS
            def #{f}?
              self.#{f} ? true : false
            end
          EOS
        end
      end
    end
  end

end
