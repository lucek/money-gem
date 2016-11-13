# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dawandamoney/version'

Gem::Specification.new do |spec|
  spec.name          = "dawandamoney"
  spec.version       = Dawanda::VERSION
  spec.authors       = ["lucek"]
  spec.email         = ["lukasz.odziewa@gmail.com"]
  spec.summary       = "Money gem created for Dawanda"
  spec.description   = "Money gem created for Dawanda coding challenge"
  spec.homepage      = "https://github.com/lucek/money-gem"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
