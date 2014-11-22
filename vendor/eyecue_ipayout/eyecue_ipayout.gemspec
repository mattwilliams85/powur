# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'eyecue_ipayout/version'

Gem::Specification.new do |spec|
  spec.name          = 'eyecue_ipayout'
  spec.version       = EyecueIpayout::VERSION
  spec.authors       = ['Danny mcalerney']
  spec.email         = ['daniel.mcalerney@eyecuelab.com']
  spec.summary       = ['Integrate the iPayout eWallet API with your ROR app']
  spec.description   = ['coming soon....']
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files = Dir['lib/**/*'] + ['Rakefile', 'README.md']
  spec.test_files = Dir['spec/**/*']
  # spec.files         = `git ls-files -z`.split("\x0")
  # spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  # spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  # spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'webmock'
  spec.add_development_dependency 'factory_girl_rails', '~> 4.0'
  spec.add_dependency 'hashie'
  spec.add_dependency 'faraday'
  spec.add_dependency 'faraday_middleware'
  spec.add_dependency 'multi_json'
  spec.add_dependency 'extlib'
end
