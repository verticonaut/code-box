# encoding: utf-8

require 'helper'

class TestActsAsCode < Test::Unit::TestCase

  def test_constants
    assert_equal 'single', Codes::CivilStatus::CodeSingle
  end

  def test_constants
    assert_equal 2, Codes::CivilStatus::all.size

    assert_equal Codes::CivilStatus.for_code('single'),  Codes::CivilStatus::all.first
    assert_equal Codes::CivilStatus.for_code('married'), Codes::CivilStatus::all.last
  end

  def test_ar_code_all
    Codes::ArCode.delete_all

    Codes::ArCode.create(:code => 'code_1', :name => "Code_1_name")
    Codes::ArCode.create(:code => 'code_2', :name => "Code_2_name")

    assert_equal 2, Codes::ArCode.all.size
  end

  def test_ar_code_lookup
    Codes::ArCode.delete_all
    code_1 = Codes::ArCode.create(:code => 'code_1', :name => "Code_1_name")
    code_2 = Codes::ArCode.create(:code => 'code_2', :name => "Code_2_name")

    assert_equal code_2, Codes::ArCode.for_code('code_2')
  end

  def test_constant_definition
    assert Codes::CivilStatus.const_defined?('CodeSingle')
    assert Codes::CivilStatus.const_defined?('CodeMarried')

    assert_equal Codes::CivilStatus::CodeMarried, 'married'
    assert_equal Codes::CivilStatus::CodeSingle,  'single'
  end

  def test_code_translation
    code = Codes::CivilStatus.new('married')

    assert_equal code.translated_code, 'married'
    assert_equal code.translated_code(:de), 'verheiratet'
  end

end