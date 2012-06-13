# ------------------------------------------------------
# Defined the respective AR Models
# ------------------------------------------------------
module Code
  class SampleClass < ActiveRecord::Base
    self.table_name = :code_sample_class

    include CodeBox::CodeAttribute

    code_attribute :gender
    code_attribute :country, :lookup => :i18n, :code_attribute_suffix => 'iso'
  end
end
