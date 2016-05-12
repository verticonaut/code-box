module CodeBox
  module ActsAsCode

    # set default for basic settings
    class << self
      attr_accessor :i18n_model_segment
    end
    @i18n_model_segment ||= 'model'

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def acts_as_code(*codes, **options)
        _module = ::CodeBox::Utilities.ensure_module(self, module_base_name: 'CodeBoxActsAsCode')
        ::CodeBox::Utilities::ActsAsCode.add_module_body(_module, codes: codes, options: options)

        self.include _module
        self.extend  _module::ClassMethods

        (class << self; self; end).include _module::ClassInstanceMethods
      end
    end

    def define_codes(mod, codes, model_tpe, define_test_methods, code_attr, model_type, base)
      # --- Define the code constants...
      module_name  = code_attr.pluralize.camelize
      codes_module = mod.const_set(module_name, Module.new)

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
          mod.module_eval method_defs, __FILE__, line_no
        end
      end

      return if model_type == :active_record

      # --- Define the code instance constants...
      constants = {}
      codes.each do |code|
        constant_name            = "#{code.to_s.camelize}"
        binding.pry
        constant                 = mod.const_set(constant_name, base.new(code.to_s))
        constants[constant_name] = constant
      end

      mod.const_set('All', constants.values.compact)

      line_no = __LINE__; method_defs = <<-RUBY
        def self.all
          All
        end
      RUBY
      mod::ClassMethods.module_eval method_defs, __FILE__, line_no
    end

  end
end

