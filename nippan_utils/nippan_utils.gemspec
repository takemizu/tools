# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'nippan_utils/version'

Gem::Specification.new do |spec|
  spec.name          = "nippan_utils"
  spec.version       = NippanUtils::VERSION
  spec.authors       = ["mizutani.takehiro"]
  spec.email         = ["Takehiro.Mizutani@np-nippan.co.jp"]
  spec.summary       = %q{Nippan Environment Utilities.}
  spec.description   = %q{Nippan Environment Utilities.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end
