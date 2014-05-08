require 'rubygems'
require 'minitest/autorun'
require 'fileutils'
require 'active_record'
require 'logger'

# ------------------------------------------------------
# Setup AR environment
# ------------------------------------------------------

# Define connection info
ActiveRecord::Base.configurations = {
  "test" => {
    :adapter  => 'sqlite3',
    :database => ':memory:'
  }
}
ActiveRecord::Base.establish_connection("test")

# Setup logger
tmp = File.expand_path('../../tmp', __FILE__)
FileUtils.mkdir_p(tmp)
ActiveRecord::Base.logger = Logger.new("#{tmp}/debug.log")

# I18n
I18n.load_path += Dir[File.expand_path('resources/locale/*.yml', File.dirname(__FILE__))]
I18n.default_locale = :en

puts :i18n_load => I18n.load_path

# ------------------------------------------------------
# Inject audit-trascer
#   and setup test schema
#   and define models used in tests
# ------------------------------------------------------
require "code-box"

require "resources/schema.rb"
require "resources/models.rb"
