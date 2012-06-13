# encoding: utf-8

require 'helper'

class TestCodeAttribute < Test::Unit::TestCase

  def setup
  end

  def test_acts_as_code_i18n_lookup
    obj = Code::SampleClass.new(gender_code: 'f', country_iso: 'de')

    assert_equal('f',      obj.gender_code)
    assert_equal('female', obj.gender)

    assert_equal('de',      obj.country_iso)
    assert_equal('Germany', obj.country)

    assert_equal('f',        obj.gender_code)
    assert_equal('weiblich', obj.gender(:de))

    assert_equal('de',          obj.country_iso)
    assert_equal('Deutschland', obj.country(:de))

    # I18n.locale = :de

    # assert_equal(obj.gender_code, 'f')
    # assert_equal(obj.gender, 'weiblich')

    # assert_equal(obj.country_iso, 'de')
    # assert_equal(obj.country, 'Deutschland')
  end


end