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
        i18n_model_segment  = opts[:i18n_model_segment] || ::CodeBox::ActsAsCode.i18n_model_segment
        model_type          = base.ancestors.include?('ActiveRecord::Base'.constantize) ? :active_record : :poro

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
                I18n.t(code_key, options.merge(scope: "#{i18n_model_segment}.values.#{base.name.underscore}.#{code_attr}"))
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

        _module.module_eval method_defs, __FILE__, line_no

        base.include _module
        base.extend  _module::ClassMethods

        case model_type
          when :active_record

            order_expression = if base.attribute_names.include?(position_attr) then
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
                All
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
            base.class_eval method_defs, __FILE__, line_no

          else
            raise ArgumentError, "'#{model_type}' is not a valid type. Use :active_record or :poro(default) instead"
        end

        define_codes(_module, codes, model_type, define_test_methods, code_attr, model_type, base)
      end

      def define_codes(_module, codes, model_tpe, define_test_methods, code_attr, model_type, base)
        # --- Define the code constants...
        module_name  = code_attr.pluralize.camelize
        codes_module = _module.const_set(module_name, Module.new)

        codes = base.all.map(&code_attr.to_sym) if model_type == :active_record

        # Create a constant for each code
        constants = {}
        codes.each do |code|
          constant_name            = code.to_s.camelize
          constant                 = codes_module.const_set(constant_name, code.to_s)
          constants[constant_name] = constant
        end

        codes_module.const_set('All', constants.values.compact)


        # Define test methods for each code like e.g.
        # def married?
        #   code == Codes::Married
        # end
        if define_test_methods
          method_prefix = CodeBox.test_method_prefix

          codes.each do |code|
            method_name = "#{method_prefix}#{code.to_s}"

            line_no = __LINE__; method_defs = <<-RUBY
              def #{method_name}?
                #{code_attr} == #{module_name}::#{code.to_s.camelize}
              end
            RUBY
            _module.module_eval method_defs, __FILE__, line_no
          end
        end

        return if model_type == :active_record # so far…

        # --- Define the code instance constants...
        constants = {}
        codes.each do |code|
          constant_name            = "#{code.to_s.camelize}"
          constant                 = _module.const_set(constant_name, base.new(code.to_s))
          constants[constant_name] = constant
        end

        _module.const_set('All', constants.values.compact)

        line_no = __LINE__; method_defs = <<-RUBY
          def self.all
            "#{_module}".constantize::All
          end
        RUBY
        base.instance_eval method_defs, __FILE__, line_no
      end

      module_function :add_module_body, :define_codes

    end
  end
end
