# encoding: utf-8

require 'helper'

class TestActsAsCode < Test::Unit::TestCase

  def test_all_methods
    assert_equal 2, Codes::CivilStatus.all.size

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

  def test_code_constant_definitiones
    # Constants
    assert Codes::CivilStatus.const_defined?('CodeSingle')
    assert Codes::CivilStatus.const_defined?('CodeMarried')
    assert Codes::CivilStatus.const_defined?('AllCodes')

    # Constants-Values
    assert_equal [Codes::CivilStatus::CodeSingle, Codes::CivilStatus::CodeMarried], Codes::CivilStatus::AllCodes
    assert_equal Codes::CivilStatus::CodeMarried, 'married'
    assert_equal Codes::CivilStatus::CodeSingle,  'single'
  end

  def test_code_instance_constant_definitions
    # Constants
    assert Codes::CivilStatus.const_defined?('Single')
    assert Codes::CivilStatus.const_defined?('Married')
    assert Codes::CivilStatus.const_defined?('All')

    # Constants-Values
    assert_equal [Codes::CivilStatus::Single, Codes::CivilStatus::Married], Codes::CivilStatus::All
    assert_equal [Codes::CivilStatus::Single, Codes::CivilStatus::Married], Codes::CivilStatus.all
    assert_equal Codes::CivilStatus::Single.code,  'single'
    assert_equal Codes::CivilStatus::Married.code, 'married'
  end

  def test_code_instance_constant_definitions_w_define_code
    # Constants
    assert Codes::CivilStatusUseDefine.const_defined?('Single')
    assert Codes::CivilStatusUseDefine.const_defined?('Married')
    assert Codes::CivilStatusUseDefine.const_defined?('All')

    # Constants-Values
    assert_equal [Codes::CivilStatusUseDefine::Single, Codes::CivilStatusUseDefine::Married], Codes::CivilStatusUseDefine::All
    assert_equal [Codes::CivilStatusUseDefine::Single, Codes::CivilStatusUseDefine::Married], Codes::CivilStatusUseDefine.all
    assert_equal Codes::CivilStatusUseDefine::Single.code,  'single'
    assert_equal Codes::CivilStatusUseDefine::Married.code, 'married'
  end

  def test_code_translation
    code = Codes::CivilStatus.new('married')

    assert_equal code.translated_code, 'married'
    assert_equal code.translated_code(:de), 'verheiratet'
  end

  def test_options_building
    options_array = Codes::CivilStatus.build_options
    assert_equal options_array.size, 2

    options_array = Codes::CivilStatus.build_options(include_nil: true)
    puts arrrr: options_array
    assert_equal options_array.size, 3
  end

end