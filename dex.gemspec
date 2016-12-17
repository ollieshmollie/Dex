# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dex/version'

Gem::Specification.new do |spec|
  spec.name          = "dex"
  spec.version       = Dex::VERSION
  spec.authors       = ["ollieshmollie"]
  spec.email         = ["oliverduncan@icloud.com"]

  spec.summary       = %q{A command line rolodex.}
  spec.homepage      = "https://www.github.com/ollieshmollie/dex"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.executables   = ["dex"]
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "sqlite3", "~> 1.3"
  spec.add_runtime_dependency "colored", "~> 1.2"

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
end
