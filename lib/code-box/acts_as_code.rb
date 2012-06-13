
# encoding: utf-8

module CodeBox

  module ActsAsCode
    @opts = {}

    def self.[](options={})
      @opts = options
      self
    end

    def self.included(base)
      base.extend(ClassMethods)
      base.acts_as_code(@opts)
    end


    module ClassMethods
      DefaultOptions = {
          :code_attribute            => :code,
          :polymorphic               => false,
          :position_attribute        => :position,
          :uniqueness_case_sensitive => false
      }

      def acts_as_code(options={})
        opts           = DefaultOptions.merge(options)
        code_attr      = opts[:code_attribute]
        position_attr  = opts[:position_attribute]
        case_sensitive = opts[:uniqueness_case_sensitive]

        order_expression = if position_attr then
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

          def self.for(code)
            code_cache[code]
          end

          def hash
            (self.class.name + '#' + #{code_attr}).hash
          end

          def equal?(other)
            other && is_a?(other.class) && #{code_attr} == other.#{code_attr}
          end
        CODE

        instance_eval <<-CODE
          class << self
            def code_cache
              @code_cache ||= initialize_cache
            end
          end
        CODE
      end
    end
  end
end

