# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'spare/version'

Gem::Specification.new do |spec|
  spec.name          = "spare"
  spec.version       = Spare::VERSION
  spec.authors       = ["Joshua Mckinney"]
  spec.email         = ["joshmckin@gmail.com"]
  spec.summary       = %q{StoredProcedure models for ActiveRecord.}
  spec.description   = %q{Provides stored procedure modeling for ruby applications that use ActiveRecord}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  
  spec.add_runtime_dependency 'activerecord', '>= 3.0', '< 5.0'
  
  spec.add_development_dependency "rspec", '~> 3.0'
  spec.add_development_dependency "rspec-autotest"
  spec.add_development_dependency "autotest"
  spec.add_development_dependency "factory_girl"
  spec.add_development_dependency "mysql2"#, '~> 0.3.10'
end
