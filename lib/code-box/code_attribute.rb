# encoding: utf-8

module CodeBox
  module CodeAttribute

    def self.[](*options)
      instance_eval <<-RUBY_
        class << self
          def _code_box_i18n_model_segment
            "#{options.extract_options![:i18n_model_segment]}"
          end
        end
      RUBY_
      self
    end

    def self.included(base)
      unless (class << self; self; end).method_defined?(:_code_box_i18n_model_segment)
        instance_eval <<-RUBY_
          class << self
            def _code_box_i18n_model_segment
              nil
            end
          end
        RUBY_
      end

      base.extend(ClassMethods)

      instance_eval <<-RUBY_
        class << base
          def _code_box_i18n_model_segment
            return CodeBox.i18n_model_segment if "#{self._code_box_i18n_model_segment}".empty?
            "#{self._code_box_i18n_model_segment}"
          end
        end
      RUBY_
    end


    module ClassMethods
      DefaultOptions = {
        foreign_code_attribute: :code,
        lookup_type:            :i18n,
        code_attribute_suffix:  'code',
        enum:                   false,
      }

      def code_attribute(*code_names)
        options                = code_names.extract_options!
        opts                   = DefaultOptions.merge(options)
        lookup_type            = opts.delete(:lookup_type)
        code_attr_suffix       = (opts.delete(:code_attribute_suffix) || "code").to_s
        foreign_code_attr_name = opts.delete(:foreign_code_attribute)
        enum                   = opts.delete(:enum)



        code_names.each do |code_name|
          opts_copy = opts.dup
          code_attr_name  = (opts_copy.delete(:attribute_name) || "#{code_name}_#{code_attr_suffix}").to_s
          code_class_name = opts_copy.delete(:class_name) || "::Codes::#{code_name.to_s.camelize}"

          case lookup_type
            when :lookup

              case enum
                when :set
                  class_eval <<-RUBY_
                    # getter
                    def #{code_name}
                      codes = #{code_attr_name}.split(',').map(&:strip)
                      codes.map{ |code| #{code_class_name}.for_code(code) }
                    end

                    # setter
                    def #{code_name}=(code_obj)
                      code_objs = Array(code_obj)
                      value     = code_objs.map{ |code_obj| code_obj.#{foreign_code_attr_name} }.join(',')
                      self.#{code_attr_name} = value
                    end

                    # getter raw
                    # not getter raw - it's defined already

                    def #{code_attr_name}_list=(codes)
                      self.#{code_attr_name} = Array(codes).join(',')
                    end
                  RUBY_
                when :binary
                  raise ArgumentError, "#:binary is not yet supported enum option"
                when false
                  class_eval <<-RUBY_
                    # getter
                    def #{code_name}
                      #{code_class_name}.for_code(#{code_attr_name})
                      end

                    # setter
                    def #{code_name}=(code)
                      value = code.#{foreign_code_attr_name}
                      self.#{code_attr_name} = value
                    end
                  RUBY_
                else
                  raise ArgumentError, "#{enum} is not a valid enum: option"
              end

            when :associated
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
                  code = self.#{code_attr_name}
                  self.class.translate_#{code_attr_name}(code, :locale => locale)
                end

                # setter
                def #{code_name}=(code)
                  raise "#{code_name} is a i18n code and can not be set. Use the the correct method '#{code_attr_name}='' instead."
                end

                # translator
                class << self
                  def translate_#{code_attr_name}(*code)
                    options           = code.extract_options!
                    locale            = options[:locale] || I18n.locale
                    codes             = code.first
                    is_paramter_array = codes.kind_of? Array

                    codes = Array(codes)
                    translated_codes = codes.map { |code|
                      code_key = code.nil? ? :null_value : code
                      I18n.t("\#{self._code_box_i18n_model_segment}.values.\#{self.name.underscore}.#{code_attr_name}.\#{code_key}", :locale => locale)
                    }

                    if options[:build] == :zip
                      translated_codes.zip(codes)
                    else
                      is_paramter_array ? translated_codes : translated_codes.first
                    end
                  end
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
