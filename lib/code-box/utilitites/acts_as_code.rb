module CodeBox
  module Utilities
    module ActsAsCode

      DefaultOptions = {
        code_attribute:            'code',
        sti:                       false,
        uniqueness_case_sensitive: true,
        position_attr:             :position,
        define_test_methods:       true,
      }

      def add_module_body(base, _module, codes:, options:)
        opts                = DefaultOptions.merge(options)
        code_attr           = opts[:code_attribute].to_s
        position_attr       = opts[:position_attribute]
        case_sensitive      = opts[:uniqueness_case_sensitive]
        define_test_methods = opts[:define_test_methods]
        model_type          = self.ancestors.include?('ActiveRecord::Base'.constantize) ? :active_record : :poro

        line_no = __LINE__; method_defs = <<-RUBY
          def translated_#{code_attr}(locale = I18n.locale, *options)
            locale_options = options.extract_options!
            locale_options.merge!({:locale => locale})
            self.class.translate_#{code_attr}(#{code_attr}, locale_options.merge({:locale => locale}))
          end

          module ClassMethods
            def translate_#{code_attr}(*codes_and_options)
              options            = codes_and_options.extract_options!
              codes              = codes_and_options.first
              is_parameter_array = codes.kind_of? Array

              codes = Array(codes)
              translated_codes = codes.map do |code|
                code_key = code.nil? ? :null_value : code
                I18n.t(CodeBox::Utilities.i18n_attribute_value_key(base, code_attr, code_key), options)
              end

              if options[:build] == :zip
                translated_codes.zip(codes)
              else
                is_parameter_array ? translated_codes : translated_codes.first
              end
            end
          end

          module ClassInstanceMethods
            def initialize_cache
              Hash[all.map{ |code| [code.#{code_attr}, code] }]
            end

            def for_code(code)
              code_cache[code]
            end

            def code_cache
              @code_cache ||= initialize_cache
            end

            def clear_code_cache
              @code_cache = nil
            end
          end
        RUBY

        mod.module_eval method_defs, __FILE__, line_no

        case model_type
          when :active_record

            order_expression = if self.attribute_names.include?(position_attr) then
              "coalesce(#{position_attr.to_s}, #{code_attr.to_s})"
            else
              code_attr.to_s
            end

            base.class_eval <<-RUBY
              validates_presence_of   :#{code_attr}
              validates_uniqueness_of :#{code_attr}#{opts[:sti] ? ', :scope => :type' : ' '}, :case_sensitive => #{case_sensitive}

              default_scope -> { order('#{order_expression}') }
            RUBY
          when :poro
            _order_attr = position_attr ? position_attr.to_s : code_attr.to_s

            line_no = __LINE__; method_defs = <<-RUBY
              # attr_accessor :#{code_attr}

              def initialize(#{code_attr})
                @#{code_attr} = #{code_attr}
              end

              def self.all
                raise 'Class responsibility - implement method .all returning all code models.'
              end

              def hash
                [self.class.name, #{code_attr}].hash
              end

              def eql?(other)
                other.is_a?(self.class) && self.hash == other.hash
              end

              def ==(other)
                self.equal? other
              end
            RUBY
            mod.module_eval method_defs, __FILE__, line_no
          else
            raise ArgumentError, "'#{model_type}' is not a valid type. Use :active_record or :poro(default) instead"
        end

        define_codes(mod, codes, model_type, define_test_methods, code_attr, model_type, base)
      end

      module_function :add_module_body
    end
  end
end
