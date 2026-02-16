# frozen_string_literal: true

require_relative 'lib/simple_prompt/version'

Gem::Specification.new do |spec|
  spec.name = 'simple_input'
  spec.version = SimplePrompt::VERSION
  spec.licenses = ['MIT']
  spec.summary = 'A simple input library for Ruby'
  spec.description = "This is a simple prompt library for ruby. Inspired by golang's huh! library's input component (https://github.com/charmbracelet/huh). If somebody needs it, I would make select, multi-select, confirm, text library in addition with AI. But my use case I need input only, so I simply AI tested it only. Not the situation in really use case."
  spec.authors = ['Hiroaki Satou']
  spec.email = 'hiroakisatou@example.com'
  spec.files = Dir['lib/**/*.rb']
  spec.homepage = 'https://github.com/hiroakisatou/simple-prompt'
  spec.metadata = { 'source_code_uri' => 'https://github.com/hiroakisatou/simple-prompt',
                    'rubygems_mfa_required' => 'true' }
  spec.required_ruby_version = '>= 3.4'

  spec.require_paths = ['lib']

  spec.add_dependency 'sorbet-runtime', '~> 0.5.100'

  spec.add_development_dependency 'rspec', '~> 3.12'
  spec.add_development_dependency 'rubocop', '~> 1.50'
  spec.add_development_dependency 'rubocop-rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop-sorbet', '~> 0.6.0'
  spec.add_development_dependency 'sorbet', '~> 0.5.100'
end
