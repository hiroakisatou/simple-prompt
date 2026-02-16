# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.2] - 2026-02-17

### Changed
- Updated type signatures to use `T.untyped` for `@reader` and `@writer` to support RSpec mocks and test doubles
- Changed `with_context` parameter names from `r, w` to `reader, writer` for better clarity

### Added
- Area calculator example (`examples/area_calculator.rb`) demonstrating practical usage with numeric conversion
- Area calculator RSpec test example (`examples/area_calculator_spec.rb`) showing how to test with mocks
- Complete example section in README with area calculator implementation and testing

### Fixed
- Mock compatibility: Input class now works seamlessly with RSpec doubles and instance_double

## [0.2.1] - 2026-02-16

### Changed
- Repository structure reorganized: moved contents from `simple-input/` subdirectory to root
- Updated repository references and documentation

## [0.2.0] - Previous Release

### Added
- Value conversion support with `convert_func` method
- Ability to transform input values (e.g., string to integer, array)
- Comprehensive examples for conversion patterns

### Changed
- Enhanced error handling for conversion failures
- Improved validation before conversion

## [0.1.1] - Initial Release

### Added
- Basic interactive input with fluent API
- Built-in validators (`:not_empty`)
- Custom validator support (Proc, Lambda, Block)
- Custom validator provider support with `with_validators`
- Multiple validator chaining
- Signal handling (Ctrl-C, Ctrl-D)
- Comprehensive examples and documentation

[0.2.2]: https://github.com/hiroakisatou/simple-prompt/compare/v0.2.1...v0.2.2
[0.2.1]: https://github.com/hiroakisatou/simple-prompt/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/hiroakisatou/simple-prompt/compare/v0.1.1...v0.2.0
[0.1.1]: https://github.com/hiroakisatou/simple-prompt/releases/tag/v0.1.1
