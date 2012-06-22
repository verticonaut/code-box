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
  end

  class CivilStatus
    include CodeBox::ActsAsCode['single', 'married', :type => :poro]

    attr_accessor :code

    def initialize(code)
      @code = code
    end

    def self.all
      [
        Codes::CivilStatus.new('single'),
        Codes::CivilStatus.new('married'),
      ]
    end
  end

  class AgerType
    @@code_cache = {}
    attr_accessor :code_id

    def initialize(code)
      @code_id = code
      self.class.cache_code(self)
    end

    def self.cache_code(code_obj)
      @@code_cache[code_obj.code_id] = code_obj
    end

    def self.for_code(code)
      @@code_cache[code]
    end
  end

  class Country < ActiveRecord::Base
    self.table_name = :codes_country
  end


  class ArCode < ActiveRecord::Base
    self.table_name = :codes_ar_code
    include CodeBox::ActsAsCode[:type => :active_record]
  end

  class SegmentModel
    include CodeBox::CodeAttribute[:i18n_model_segment => :model]

    attr_accessor :gender_code

    # i18n codes
    code_attribute :gender
  end

end
