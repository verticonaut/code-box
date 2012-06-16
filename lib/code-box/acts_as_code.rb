
# encoding: utf-8

module CodeBox

  module ActsAsCode
    @opts = {}

    def self.[](*options)
      @opts = options
      self
    end

    def self.included(base)
      base.extend(ClassMethods)
      base.acts_as_code(*@opts) if @opts.size > 0
    end


    module ClassMethods
      DefaultOptions = {
          :model_type                => :poro,
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
        model_type     = opts.delete(:model_type)

        # Create a constant for each code
        codes.each do |code|
          const_set("Code#{code.to_s.camelize}", code)
        end

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

              def self.initialize_cache
                all.inject({}) {|hash, obj| hash[obj.#{code_attr}] = obj; hash }
              end

              def self.lookup(code)
                code_cache[code]
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
            CODE

            instance_eval <<-CODE
              class << self
                def code_cache
                  @code_cache ||= initialize_cache
                end
              end
            CODE

          when :poro
            order_attr = position_attr ? position_attr.to_s : code_attr.to_s

            class_eval <<-CODE
              def self.initialize_cache
                all.inject({}) {|hash, obj| hash[obj.#{code_attr}] = obj; hash }
              end

              def self.lookup(code)
                code_cache[code]
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

            instance_eval <<-CODE
              class << self
                def code_cache
                  @code_cache ||= initialize_cache
                end
              end
            CODE

          else
            raise ArgumentError, "'#{model_type}' is not a valid type. Use :active_record or :poro(default) instead"
        end

      end
    end
  end
end

