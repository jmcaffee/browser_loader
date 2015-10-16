# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'browser_loader/version'

Gem::Specification.new do |spec|
  spec.name          = "browser_loader"
  spec.version       = BrowserLoader::VERSION
  spec.authors       = ["Jeff McAffee"]
  spec.email         = ["jeff@ktechsystems.com"]
  spec.summary       = %q{Watir-webdriver based browser loader class.}
  spec.description   = %q{Watir-webdriver based browser loader class providing additional chromium configuration options.}
  spec.homepage      = "https://github.com/jmcaffee/browser_loader"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-byebug"

  spec.add_runtime_dependency "watir-webdriver"
  spec.add_runtime_dependency "ktutils"
end
