# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'angular/version'

Gem::Specification.new do |spec|
  spec.name          = "capybara-angular"
  spec.version       = Angular::VERSION
  spec.authors       = ["kari"]
  spec.email         = ["mr.kari.ikonen@gmail.com"]
  spec.summary       = %q{AngularJS for capybara.}
  spec.description   = %q{AngularJS for capybara.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
