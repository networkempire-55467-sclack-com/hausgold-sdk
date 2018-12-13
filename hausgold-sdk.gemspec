# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hausgold/version'

Gem::Specification.new do |spec|
  spec.name          = 'hausgold-sdk'
  spec.version       = Hausgold::VERSION
  spec.authors       = ['Hermann Mayer']
  spec.email         = ['hermann.mayer92@gmail.com']

  spec.summary       = 'Connect your app to the HAUSGOLD ecosystem'
  spec.description   = 'Connect your app to the HAUSGOLD ecosystem'
  spec.homepage      = 'https://github.com/hausgold/hausgold-sdk'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rack', '~> 2.0'
  spec.add_development_dependency 'rack-test', '~> 0.8.2'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'simplecov', '~> 0.15'
  spec.add_development_dependency 'timecop', '~> 0.9.1'
  spec.add_development_dependency 'vcr', '~> 3.0'
  spec.add_development_dependency 'webmock', '~> 3.1'

  spec.add_runtime_dependency 'activesupport', '>= 3.2.0'
  spec.add_runtime_dependency 'httparty'
  spec.add_runtime_dependency 'recursive-open-struct', '~> 1.0'
end