# Simple Input

this is a simple prompt library for ruby.
inspired by golang's huh! library's input component.
https://github.com/charmbracelet/huh

## Requirements

- Ruby 3.4+
- Bundler

## Installation

```bash
git clone <this-repo>
cd simple-input
bundle install
```

or

```bash
gem install simple_input
```

## Usage

### Basic Input

```ruby
require_relative 'input'

name = Input.new_input
             .title('What is your name?')
             .prompt('> ')
             .validate(:not_empty)
             .run

puts "Hello, #{name}!"
```

### Custom Prompt

```ruby
email = Input.new_input
              .title('Enter your email')
              .prompt('email> ')
              .validate { |val| val.include?('@') ? nil : 'Please enter a valid email' }
              .run
```

### Multiple Validators

Validators run in order. The first error found is displayed.

```ruby
password = Input.new_input
                 .title('Create a password')
                 .prompt('password> ')
                 .validate(:not_empty)
                 .validate { |val| val.length < 8 ? 'Must be at least 8 characters' : nil }
                 .run
```

### Custom Validator Provider

By default, symbol validators (e.g., `:not_empty`) resolve against `DefaultValidators`. You can swap in your own module with `with_validators`:

```ruby
module MyValidators
  module_function

  def email(val)
    val.match?(/\A[^@\s]+@[^@\s]+\z/) ? nil : 'Invalid email format'
  end

  def min_length(val)
    val.length >= 3 ? nil : 'Must be at least 3 characters'
  end
end

username = Input.new_input
                .with_validators(MyValidators)
                .validate(:min_length)
                .run
```

### Validation Types

You can pass validators in three ways:

| Type | Example |
|------|---------|
| **Symbol** | `.validate(:not_empty)` - looks up method on the validator provider |
| **Proc/Lambda** | `.validate(-> (val) { val.empty? ? 'required' : nil })` |
| **Block** | `.validate { \|val\| val.empty? ? 'required' : nil }` |

Validators are functions that take a `String` and return `nil` (valid) or an error message `String`.

### Value Conversion

Use `convert_func` to transform the input value before it's returned. This is useful for converting strings to integers, floats, arrays, or any other type.

```ruby
# Convert to integer
age = Input.new_input
           .title('How old are you?')
           .validate(:not_empty)
           .validate { |val| val.match?(/^\d+$/) ? nil : 'Must be a number' }
           .convert_func { |val| val.to_i }
           .run

puts age.class  # => Integer
```

```ruby
# Convert to array
tags = Input.new_input
            .title('Enter tags (comma-separated)')
            .convert_func { |val| val.split(',').map(&:strip) }
            .run

puts tags.inspect  # => ["ruby", "cli", "prompt"]
```

You can pass a converter in two ways:

| Type | Example |
|------|---------|
| **Proc/Lambda** | `.convert_func(-> (val) { val.to_i })` |
| **Block** | `.convert_func { \|val\| val.to_i }` |

Converters are functions that take a `String` and return any type. Validation happens before conversion.

**Important:** If conversion fails with an exception, an error message will be displayed prompting you to add validation. Always validate input before conversion to prevent errors:

```ruby
# ❌ Bad - conversion can fail without validation
age = Input.new_input
           .convert_func { |val| Integer(val) }  # Raises exception on invalid input
           .run

# ✅ Good - validate before conversion
age = Input.new_input
           .validate(:not_empty)
           .validate { |val| val.match?(/^\d+$/) ? nil : 'Must be a number' }
           .convert_func { |val| val.to_i }
           .run
```

### Signal Handling

- **Ctrl-C** - Prints `(canceled)` and exits gracefully
- **Ctrl-D (EOF)** - Returns an empty string

## API

| Method | Description |
|--------|-------------|
| `Input.new_input` | Factory method to create a new Input (`.new` is private) |
| `#title(text)` | Set the title displayed above the prompt |
| `#prompt(text)` | Set the prompt string (default: `"> "`) |
| `#validate(validator, &block)` | Add a validator (Symbol, Proc, or block) |
| `#with_validators(provider)` | Set a custom validator provider module |
| `#convert_func(converter, &block)` | Set a converter function to transform the input value |
| `#run` | Start the interactive input loop and return the result |

All methods (except `#run`) return `self` for chaining.

## Complete Example: Area Calculator

Here's a practical example that demonstrates validation, conversion, and dependency injection for testing:

```ruby
class AreaCalculator
  def initialize(reader = $stdin, writer = $stdout)
    @reader = reader
    @writer = writer
  end

  # Reusable conversion function
  def to_number
    ->(value) do
      if value.to_i.to_s == value
        value.to_i
      elsif value.to_f.to_s == value
        value.to_f
      else
        raise ArgumentError, "Invalid number: #{value}"
      end
    end
  end

  def input_length
    Input.new_input
      .send(:with_context, @reader, @writer)
      .title('What is the length of the room in feet?')
      .validate { |value| value.to_i > 0 ? nil : 'Length must be a positive number' }
      .convert_func(to_number)
      .run
  end

  def input_width
    Input.new_input
      .send(:with_context, @reader, @writer)
      .title('What is the width of the room in feet?')
      .validate { |value| value.to_i > 0 ? nil : 'Width must be a positive number' }
      .convert_func(to_number)
      .run
  end

  def calculate_area
    length = input_length
    width = input_width
    area = length * width

    @writer.puts "\nYou entered dimensions of #{length} feet by #{width} feet."
    @writer.puts "The area is #{area} square feet"
  end
end
```

This example can be tested with RSpec using mocks:

```ruby
RSpec.describe AreaCalculator do
  let(:writer) { double('writer') }
  let(:reader) { double('reader') }
  subject(:calculator) { AreaCalculator.new(reader, writer) }

  before do
    allow(writer).to receive(:puts)
    allow(writer).to receive(:print)
  end

  it 'returns integer for valid integer input' do
    allow(reader).to receive(:gets).and_return("10\n")

    result = calculator.input_length

    expect(result).to eq(10)
  end

  it 'returns float for valid float input' do
    allow(reader).to receive(:gets).and_return("10.5\n")

    result = calculator.input_length

    expect(result).to eq(10.5)
  end
end
```

See `examples/area_calculator.rb` and `examples/area_calculator_spec.rb` for the complete implementation.

## Running Examples

```bash
# Basic usage and validation
ruby examples/basic.rb

# Custom validator providers
ruby examples/custom_validators.rb

# Value conversion (string to int, array, etc.)
ruby examples/convert.rb

# Common validation patterns (email, password, range, choice)
ruby examples/validation_patterns.rb

# Error handling and conversion safety
ruby examples/error_handling.rb

# Area calculator with numeric conversion (practical example)
ruby examples/area_calculator.rb
```

## Testing

```bash
bundle exec rspec
```

### Testing with `with_context` (Private Method)

The `Input` class has a private method `with_context(reader, writer)` that allows injecting custom IO objects for testing. Since `new` is also private (enforcing use of `Input.new_input`), tests use `send` to access `with_context`:

```ruby
def build_input(input_text)
  reader = StringIO.new(input_text)
  writer = StringIO.new
  input = Input.new_input
  input.send(:with_context, reader, writer)
  [input, writer]
end

# Usage in tests
it 'returns the user input' do
  input, = build_input("hello\n")
  result = input.run
  expect(result).to eq('hello')
end

it 'shows validation errors' do
  input, writer = build_input("\nhello\n")
  result = input.validate(:not_empty).run
  expect(result).to eq('hello')
  expect(writer.string).to include('入力してください')
end
```

This pattern lets you:
- Simulate user input via `StringIO` as the reader
- Capture all terminal output via `StringIO` as the writer
- Test the full input loop including validation re-prompting without interactive terminal input


## License

MIT
