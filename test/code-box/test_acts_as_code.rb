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
    Codes::ArCode.create(:code => 'code_1', :name => "Code_1_name")
    Codes::ArCode.create(:code => 'code_2', :name => "Code_2_name")

    assert_equal 2, Codes::ArCode.all.size
  end


  def test_ar_code_lookup
    code_1 = Codes::ArCode.create(:code => 'code_1', :name => "Code_1_name")
    code_2 = Codes::ArCode.create(:code => 'code_2', :name => "Code_2_name")

    assert_equal code_2, Codes::ArCode.for_code('code_2')
  end


end