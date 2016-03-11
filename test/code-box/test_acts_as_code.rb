# encoding: utf-8

require 'helper'

class TestActsAsCode < MiniTest::Unit::TestCase

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
    assert Codes::CivilStatus.const_defined?('Codes')
    assert Codes::CivilStatus::Codes.const_defined?('Single')
    assert Codes::CivilStatus::Codes.const_defined?('Married')
    assert Codes::CivilStatus::Codes.const_defined?('All')

    # Constants-Values
    assert_equal [Codes::CivilStatus::Codes::Single, Codes::CivilStatus::Codes::Married], Codes::CivilStatus::Codes::All
    assert_equal Codes::CivilStatus::Codes::Married, 'married'
    assert_equal Codes::CivilStatus::Codes::Single,  'single'
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
    assert Codes::CivilStatus.const_defined?('Single')
    assert Codes::CivilStatus.const_defined?('Married')
    assert Codes::CivilStatus.const_defined?('All')

    # Constants-Values
    assert_equal [Codes::CivilStatus::Single, Codes::CivilStatus::Married], Codes::CivilStatus::All
    assert_equal [Codes::CivilStatus::Single, Codes::CivilStatus::Married], Codes::CivilStatus.all
    assert_equal Codes::CivilStatus::Single.code,  'single'
    assert_equal Codes::CivilStatus::Married.code, 'married'
  end

  def test_code_translation
    code = Codes::CivilStatus.new('married')
    I18n.locale = :en

    assert_equal code.translated_code, 'married'
    assert_equal code.translated_code(:de), 'verheiratet'
  end

  def test_options_building
    options_array = Codes::CivilStatus.build_select_options
    assert_equal options_array.size, 2

    options_array = Codes::CivilStatus.build_select_options(include_empty: true)
    assert_equal options_array.size, 3
    assert_equal options_array.first[1], nil
  end

  def test_options_building_with_text_label
    options_array = Codes::CivilStatus.build_select_options(include_empty: { label: 'MyLabel' })
    assert_equal options_array.size, 3
    assert_equal options_array.first[0], 'MyLabel'
    assert_equal options_array.first[1], nil
  end

  def test_options_building_with_custom_value
    options_array = Codes::CivilStatus.build_select_options(include_empty: { value: 'all' })
    assert_equal options_array.size, 3
    assert_equal options_array.first[1], 'all'
  end

  def test_options_building_with_custom_label_and_value
    options_array = Codes::CivilStatus.build_select_options(include_empty: { label: 'Yaiii', value: 'all' })
    assert_equal options_array.size, 3
    assert_equal options_array.first[0], 'Yaiii'
    assert_equal options_array.first[1], 'all'
  end

end