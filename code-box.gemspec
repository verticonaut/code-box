# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require File.expand_path('../lib/code-box/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "code-box"
  gem.version       = CodeBox::VERSION
  gem.license       = "BSD-2-Clause"

  gem.authors       = ["Martin Schweizer"]
  gem.email         = ["contact@verticonaut.me"]
  gem.description   = %q{Specify attributes as code and provide lookup by I18n-, cache- or associated and support for building code classes.}
  gem.summary       = %q{Specify attributes as code and provide lookup by I18n-, cache- or associated and support for building code classes.}
  gem.homepage      = %q{http://github.com/verticonaut/code-box}

  gem.add_development_dependency  "activerecord", "~> 7.0"
  gem.add_development_dependency  "sqlite3"
  gem.add_development_dependency  "rake"
  gem.add_development_dependency  "minitest"
  gem.add_development_dependency  "bigdecimal"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.rdoc_options  << "--charset" << "UTF-8" << "--line-numbers"
end
