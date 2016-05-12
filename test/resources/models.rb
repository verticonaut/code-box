# ------------------------------------------------------
# Defined the respective AR Models
# ------------------------------------------------------
module Codes

  class SampleClass < ActiveRecord::Base
    self.table_name = :codes_sample_class

    include CodeBox::CodeAttribute

    # i18n codes
    code_attribute :gender
    code_attribute :country,      :lookup_type => :i18n, :code_attribute_suffix => 'iso'

    # lookup codes
    code_attribute :civil_status, :lookup_type => :lookup, :class_name => 'Codes::CivilStatus'
    code_attribute :ager_type,    :lookup_type => :lookup, :foreign_code_attribute => 'code_id'

    code_attribute :country_2,    :lookup_type => :associated, :class_name => 'Codes::Country'

    code_attribute :countries,    :lookup_type => :lookup, :class_name => 'Codes::Country', :enum => :set
  end

  class CivilStatus
    include CodeBox::ActsAsCode
    acts_as_code(:single, :married, i18n_model_segment: 'activerecord')

    attr_accessor :code
  end

  class Country < ActiveRecord::Base
    include CodeBox::ActsAsCode
    self.table_name = :codes_country

    acts_as_code

    def self.for_code(code)
      where('code= ?', code).first
    end
  end

  class ArCode < ActiveRecord::Base
    include CodeBox::ActsAsCode
    self.table_name = :codes_ar_code

    acts_as_code
  end


end
