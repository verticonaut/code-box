# encoding: utf-8

module CodeBox

  module CodeAttribute

    def self.included(base)
      base.extend(ClassMethods)
    end


    module ClassMethods
      DefaultOptions = {
        :foreign_code_attribute => :code,
        :lookup                 => :i18n,
        :code_attribute_suffix  => 'code'
      }

      def code_attribute(*code_names)
        options                = code_names.extract_options!
        opts                   = DefaultOptions.merge(options)
        lookup_type            = opts.delete(:lookup)
        code_attr_suffix       = (opts.delete(:code_attribute_suffix) || "code").to_s
        foreign_code_attr_name = opts.delete(:foreign_code_attribute)

        code_names.each do |code_name|
          opts_copy = opts.dup
          code_attr_name  = (opts_copy.delete(:attribute_name) || "#{code_name}_#{code_attr_suffix}").to_s
          code_class_name = opts_copy.delete(:class_name) || "::Codes::#{code_name.to_s.camelize}"

          case lookup_type
            when :cache
              class_eval <<-RUBY_
                # getter
                def #{code_name}
                  code_class_name.constantize.for(value)
                end

                # setter
                def #{code_name}=(code)
                  value = code.#{foreign_code_attr_name}
                  #{code_attr_name} = value
                end
              RUBY_
            when :association
              association_options = opts_copy.merge({
                  :class_name  => "#{code_class_name}",
                  :foreign_key => "#{code_attr_name}".to_sym,
                  :primary_key => "#{foreign_code_attr_name}"
              })
              belongs_to "#{code_name}".to_sym, association_options
            when :i18n
              class_eval <<-RUBY_
                # getter
                def #{code_name}(locale=I18n.locale)
                  value = self.#{code_attr_name}
                  value_key = value.nil? ? :null_value : value
                  I18n.t("activerecord.\#{self.class.name.underscore}.values.#{code_attr_name}.\#{value_key}", :locale => locale)
                end

                # setter
                def #{code_name}=(code)
                  raise "#{code_name} is a i18n code and can not be set. Use the the correct method '#{code_attr_name}='' instead."
                end
              RUBY_
            else
              raise ArgumentError, "'#{lookup_type}' is not valid. Must be one of [:code_cache, :association]"
          end
        end
      end

      alias :belongs_to_code :code_attribute
    end
  end
end
