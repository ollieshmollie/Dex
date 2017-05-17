# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tact/version'

Gem::Specification.new do |spec|
  spec.name          = "tact"
  spec.version       = Tact::VERSION
  spec.authors       = ["ollieshmollie"]
  spec.email         = ["oliverduncan@icloud.com"]

  spec.summary       = %q{A command line rolodex.}
  spec.homepage      = "https://www.github.com/ollieshmollie/tact"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.files << 'client_secret.json'

  spec.executables   = ["tact"]
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "sqlite3", "~> 1.3"
  spec.add_runtime_dependency "colored", "~> 1.2"
  spec.add_runtime_dependency "activerecord", "~> 5.0"

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.6"
  spec.add_development_dependency "database_cleaner", "~> 1.4"

  spec.requirements << "oauth2l"

  spec.post_install_message = "Thanks for installing tact! Run `tact -h` for help. Note: If you would like to sync your contacts with Google, please install oauth2l: 'https://github.com/google/oauth2l'"
end
