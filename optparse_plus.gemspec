# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'optparse_plus/version'

Gem::Specification.new do |spec|
  spec.name          = "optparse_plus"
  spec.version       = OptparsePlus::VERSION
  spec.authors       = ["HASHIMOTO, Naoki"]
  spec.email         = ["hashimoto.naoki@gmail.com"]
  spec.description   = %q{"optparse_plus" will let you define command line options more easily.}
  spec.summary       = %q{"optparse_plus" adds some helper methods to OptionParser. In your script, simply require 'optparse_plus' in stead of 'optparse', then the new methods of OptionParser are available for you.}
  spec.homepage      = "https://github.com/nico-hn/optparse_plus"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
