
# encoding: utf-8

module CodeBox

  module ActsAsCode
    @opts = {}

    def self.[](*options)
      @opts = options.dup

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

      instance_eval <<-RUBY_
        class << base
          def _code_box_i18n_model_segment
            return CodeBox.i18n_model_segment if "#{self._code_box_i18n_model_segment}".empty?
            "#{self._code_box_i18n_model_segment}"
          end
        end
      RUBY_

      base.extend(ClassMethods)
      base.acts_as_code(*@opts) if @opts
    end


    module ClassMethods
      DefaultOptions = {
          :type                      => :poro,
          :code_attribute            => :code,
          :polymorphic               => false,
          :uniqueness_case_sensitive => true,
          :position_attr             => :position,
      }

      def acts_as_code(*codes_and_or_options)
        options        = codes_and_or_options.extract_options!
        codes          = codes_and_or_options
        opts           = DefaultOptions.merge(options)
        code_attr      = opts[:code_attribute]
        position_attr  = opts[:position_attribute]
        case_sensitive = opts[:uniqueness_case_sensitive]
        model_type     = opts.delete(:type)

        # Create a constant for each code
        codes.each do |code|
          const_set("Code#{code.to_s.camelize}", code)
        end

        class_eval <<-RUBY_
          def translated_#{code_attr}(locale = I18n.locale, *options)
            locale_options = options.extract_options!
            locale_options.merge!({:locale => locale})
            self.class.translate_#{code_attr}(#{code_attr}, locale_options.merge({:locale => locale}))
          end

          # translator
          class << self
            def translate_#{code_attr}(*code)
              options            = code.extract_options!
              codes              = code.first
              is_parameter_array = codes.kind_of? Array

              codes = Array(codes)
              translated_codes = codes.map { |code|
                code_key = code.nil? ? :null_value : code
                I18n.t("\#{self._code_box_i18n_model_segment}.values.\#{self.name.underscore}.#{code_attr}.\#{code_key}", options)
              }

              if options[:build] == :zip
                translated_codes.zip(codes)
              else
                is_parameter_array ? translated_codes : translated_codes.first
              end
            end
          end

          def self.for_code(code)
            code_cache[code]
          end

          def self.initialize_cache
            Hash[all.map{ |code| [code.#{code_attr}, code] }]
          end

        RUBY_

        instance_eval <<-CODE
          class << self
            def code_cache
              @code_cache ||= initialize_cache
            end

            def clear_code_cache
              @code_cache = nil
            end
          end
        CODE

        case model_type
          when :active_record

            order_expression = if self.attribute_names.include?(position_attr) then
              "coalesce(#{position_attr.to_s}, #{code_attr.to_s})"
            else
              code_attr.to_s
            end

            class_eval <<-CODE
              validates_presence_of   :#{code_attr}
              validates_uniqueness_of :#{code_attr}#{opts[:polymorphic] ? ', :scope => :type' : ' '}, :case_sensitive => #{case_sensitive}

              default_scope order('#{order_expression}')
            CODE

          when :poro
            order_attr = position_attr ? position_attr.to_s : code_attr.to_s

            class_eval <<-CODE
              attr_accessor :#{code_attr}

              def self.initialize(#{code_attr})
                self.#{code_attr} = #{code_attr}
              end

              def hash
                (self.class.name + '#' + #{code_attr}).hash
              end

              def equal?(other)
                other && is_a?(other.class) && #{code_attr} == other.#{code_attr}
              end

              def ==(other)
                self.equal? other
              end

              def self.all
                raise "Sublass responsibility. You should implement '.all' returning all codes"
              end
            CODE

          else
            raise ArgumentError, "'#{model_type}' is not a valid type. Use :active_record or :poro(default) instead"
        end

      end
    end
  end
end

