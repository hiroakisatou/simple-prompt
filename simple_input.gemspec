# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = 'simple_input'
  spec.version       = '0.2.1'
  spec.authors       = ['Hiroaki Satou']
  spec.email         = ['']

  spec.summary       = "A simple prompt library for Ruby inspired by golang's huh! library"
  spec.description   = "Simple Input provides a fluent API for creating interactive command-line prompts with validation and conversion support. Inspired by golang's huh! library's input component."
  spec.homepage      = 'https://github.com/hiroakisatou/simple-prompt'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.4.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/hiroakisatou/simple-prompt'
  spec.metadata['changelog_uri'] = 'https://github.com/hiroakisatou/simple-prompt/blob/main/CHANGELOG.md'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.glob('{lib,examples}/**/*') + %w[README.md LICENSE]
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'sorbet-runtime', '~> 0.5.100'

  spec.add_development_dependency 'rspec', '~> 3.12'
  spec.add_development_dependency 'rubocop', '~> 1.50'
  spec.add_development_dependency 'rubocop-rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop-sorbet', '~> 0.6.0'
  spec.add_development_dependency 'sorbet', '~> 0.5.100'
end
