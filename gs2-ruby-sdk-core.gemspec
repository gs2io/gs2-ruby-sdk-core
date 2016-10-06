# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gs2/core/version'

Gem::Specification.new do |spec|
  spec.name          = "gs2-ruby-sdk-core"
  spec.version       = Gs2::Core::VERSION
  spec.authors       = ["Game Server Services, Inc."]
  spec.email         = ["contact@gs2.io"]
  spec.licenses		 = "Apache-2.0"

  spec.summary       = %q{Game Server Services Core Library}
  spec.homepage      = "https://gs2.io/"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "httpclient", "~> 2"
  
  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
end