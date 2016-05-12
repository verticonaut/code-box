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
        _module = ::CodeBox::Utility.ensure_module(self, module_base_name: 'CodeBoxActsAsCode')
        ::CodeBox::Utilities::ActsAsCode.add_module_body(self, _module, codes: codes, options: options)

        self.include _module
        self.extend  _module::ClassMethods

        (class << self; self; end).include _module::ClassInstanceMethods
      end
    end
  end
end

