# encoding: utf-8

require 'code-box/code_attribute'
require 'code-box/acts_as_code'

module CodeBox
  Config = {
  	i18n_model_segment:     :activerecord,
    i18n_empty_options_key: 'shared.options.pls_select',
  	test_method_prefix:     '',
  }

  module_function

  def i18n_model_segment=(segment)
    Config[:i18n_model_segment] = segment
  end

  def i18n_model_segment
    Config[:i18n_model_segment]
  end

  def i18n_empty_options_key=(key)
    Config[:i18n_empty_options_key] = key
  end

  def i18n_empty_options_key
    Config[:i18n_empty_options_key]
  end

  def test_method_prefix=(prefix)
    Config[:test_method_prefix] = (prefix.nil? ? '' : prefix.strip)
  end

  def test_method_prefix
    Config[:test_method_prefix]
  end

end