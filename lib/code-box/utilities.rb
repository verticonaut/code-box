module CodeBox
  module Utilities

    def ensure_module(base, module_base_name: 'CodeBoxActsAsCode', prepend_base_name: true)
      module_name = module_base_name
      module_name = "#{base.name}::#{module_name}" if prepend_base_name

      begin
        mod = base.const_get(module_name)
      rescue NameError
        mod = Module.new
        base.const_set(module_name, mod)
      end

      mod
    end

    def i18n_value_scope(model_class, i18n_model_segment = CodeBox::ActsAsCode.i18n_model_segment)
      "#{i18n_model_segment}.values.#{model_class.name.underscore}"
    end

    def i18n_attribute_value_key(model_class, attribute, code_value, i18n_model_segment: CodeBox::ActsAsCode.i18n_model_segment)
      "#{i18n_value_scope(model_class, i18n_model_segment)}.#{attribute}.#{code_value}"
    end

    module_function :ensure_module, :i18n_model_segment
  end
end
