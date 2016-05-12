# encoding: utf-8

require 'code-box/utility'
require 'code-box/utilities/acts_as_code'
require 'code-box/code_attribute'
require 'code-box/acts_as_code'

module CodeBox
  Config = {
  	i18n_model_segment:     :activerecord,
  	test_method_prefix:     '',
  }

  module_function

  def i18n_model_segment=(segment)
    Config[:i18n_model_segment] = segment
  end

  def i18n_model_segment
    Config[:i18n_model_segment]
  end

  def test_method_prefix=(prefix)
    Config[:test_method_prefix] = (prefix.nil? ? '' : prefix.strip)
  end

  def test_method_prefix
    Config[:test_method_prefix]
  end

end