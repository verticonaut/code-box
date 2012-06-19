# encoding: utf-8

require 'helper'

class TestCodeAttribute < Test::Unit::TestCase

  def setup
  end

  # :type => :i18n -------------------------------------------------------------------
  def test_code_attribute_i18n_lookup
    obj = Codes::SampleClass.new(gender_code: 'f', country_iso: 'de')
    I18n.locale =:en

    assert_equal('f',      obj.gender_code)
    assert_equal('female', obj.gender)

    assert_equal('de',      obj.country_iso)
    assert_equal('Germany', obj.country)

    assert_equal('f',        obj.gender_code)
    assert_equal('weiblich', obj.gender(:de))

    assert_equal('de',          obj.country_iso)
    assert_equal('Deutschland', obj.country(:de))
  end

  def test_code_attribute_i18n_lookup_w_segment
    obj = Codes::SegmentModel.new
    obj.gender_code = 'f'
    I18n.locale =:en

    assert_equal('f',      obj.gender_code)
    assert_equal('female', obj.gender)
  end

  def test_code_attribute_i18n_translator_with_single_code
    I18n.locale = :de
    translation = Codes::SampleClass.translate_gender_code('f')
    assert_equal('weiblich', translation)

    translation = Codes::SampleClass.translate_gender_code('f', :locale => :en)
    assert_equal('female', translation)
  end

  def test_code_attribute_i18n_translator_with_multiple_codes
    I18n.locale = :de
    translation = Codes::SampleClass.translate_gender_code(['f', 'm'])

    assert translation.kind_of? Array
    assert_equal('weiblich', translation.first)
    assert_equal('männlich', translation.last)

    translation = Codes::SampleClass.translate_gender_code(['f', 'm'], :locale => :en)

    assert translation.kind_of? Array
    assert_equal('female', translation.first)
    assert_equal('male', translation.last)
  end

  def test_code_attribute_i18n_translator_with_multiple_codes_zipped
    I18n.locale = :de
    translation = Codes::SampleClass.translate_gender_code(['f', 'm'], :build => :zip)

    assert translation.kind_of? Array
    assert_equal(['weiblich', 'f'], translation.first)
    assert_equal(['männlich', 'm'], translation.last)

    translation = Codes::SampleClass.translate_gender_code(['f', 'm'], :locale => :en, :build => :zip)

    assert translation.kind_of? Array
    assert_equal(['female', 'f'], translation.first)
    assert_equal(['male', 'm'],   translation.last)
  end


  # :type => :lookup -------------------------------------------------------------------
  def test_code_attribute_lookup_default
    code_single  = Codes::CivilStatus.for_code('single')
    code_married = Codes::CivilStatus.for_code('married')

    code_client  = Codes::SampleClass.new(:civil_status_code => 'single')

    assert_equal('single',    code_client.civil_status_code)
    assert_equal(code_single, code_client.civil_status)
  end

  def test_code_attribute_lookup_custom_code_name
    code_child    = Codes::AgerType.new('child')
    code_teenager = Codes::AgerType.new('teenager')

    code_client  = Codes::SampleClass.new(:ager_type_code => 'child')

    assert_equal('child',    code_client.ager_type_code)
    assert_equal(code_child, code_client.ager_type)
  end


  # :type => :associated ----------------------------------------------------------------
  def test_code_attribute_lookup_associated
    code_ch  = Codes::Country.create(:code => 'CH', :name => 'Switzerland')
    code_de  = Codes::Country.create(:code => 'DE', :name => 'Germany')

    code_client  = Codes::SampleClass.new(:country_2_code => 'CH')

    assert_equal('CH',    code_client.country_2_code)
    assert_equal(code_ch, code_client.country_2)
  end

end