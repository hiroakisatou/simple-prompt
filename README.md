# Simple Prompt

this is a simple prompt library for ruby.
inspired by golang's huh! library's input component.
https://github.com/charmbracelet/huh

## Requirements

- Ruby 3.4+
- Bundler

## Installation

```bash
git clone <this-repo>
cd simple-prompt
bundle install
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
| `#run` | Start the interactive input loop and return the result |

All methods (except `#run`) return `self` for chaining.

## Running Examples

```bash
ruby examples/basic.rb
ruby examples/custom_validators.rb
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
