# frozen_string_literal: true

require_relative '../input'

RSpec.describe Input do
  # Helper: create an Input with injected IO using the private `with_context` method
  def build_input(input_text)
    reader = StringIO.new(input_text)
    writer = StringIO.new
    input = Input.new_input
    input.send(:with_context, reader, writer)
    [input, writer]
  end

  describe '.new_input' do
    it 'creates an Input instance' do
      expect(Input.new_input).to be_a(Input)
    end

    it 'cannot be created with .new directly' do
      expect { Input.new }.to raise_error(NoMethodError, /private method 'new'/)
    end
  end

  describe '#title' do
    it 'displays the title before prompt' do
      input, writer = build_input("hello\n")
      input.title('What is your name?').run

      output = writer.string
      expect(output).to include('What is your name?')
    end
  end

  describe '#prompt' do
    it 'uses custom prompt text' do
      input, writer = build_input("hello\n")
      input.prompt('>> ').run

      output = writer.string
      expect(output).to include('>> ')
    end

    it 'uses default "> " prompt' do
      input, writer = build_input("hello\n")
      input.run

      output = writer.string
      expect(output).to include('> ')
    end
  end

  describe '#run' do
    it 'returns the user input' do
      input, = build_input("hello world\n")
      result = input.run

      expect(result).to eq('hello world')
    end

    it 'strips whitespace from input' do
      input, = build_input("  hello  \n")
      result = input.run

      expect(result).to eq('hello')
    end

    it 'returns empty string on Ctrl-D (EOF)' do
      input, = build_input('')
      result = input.run

      expect(result).to eq('')
    end
  end

  describe '#validate' do
    context 'with a block validator' do
      it 'returns input when valid' do
        input, = build_input("good\n")
        result = input.validate { |val| val.length < 3 ? 'too short' : nil }.run

        expect(result).to eq('good')
      end

      it 're-prompts when validation fails then accepts valid input' do
        input, writer = build_input("ab\ngood\n")
        result = input.validate { |val| val.length < 3 ? 'too short' : nil }.run

        expect(result).to eq('good')
        expect(writer.string).to include('too short')
      end
    end

    context 'with a Proc validator' do
      it 'validates using the proc' do
        validator = proc { |val| val.empty? ? 'required' : nil }
        input, = build_input("hello\n")
        result = input.validate(validator).run

        expect(result).to eq('hello')
      end
    end

    context 'with a Symbol validator' do
      it 'uses the default validator provider' do
        input, writer = build_input("\nhello\n")
        result = input.validate(:not_empty).run

        expect(result).to eq('hello')
        expect(writer.string).to include('Input is required')
      end

      it 'raises ArgumentError for unknown validator' do
        input, = build_input("hello\n")

        expect { input.validate(:nonexistent) }.to raise_error(ArgumentError, /Unknown validator/)
      end
    end

    context 'with multiple validators' do
      it 'checks all validators in order' do
        input, writer = build_input("\nab\nhello\n")
        result = input
                 .validate(:not_empty)
                 .validate { |val| val.length < 3 ? 'too short' : nil }
                 .run

        expect(result).to eq('hello')
        output = writer.string
        expect(output).to include('Input is required')
        expect(output).to include('too short')
      end
    end
  end

  describe '#with_validators' do
    it 'uses a custom validator provider' do
      custom_provider = Module.new do
        module_function

        def custom_check(val)
          val.include?('@') ? nil : 'must contain @'
        end
      end

      input, writer = build_input("hello\nfoo@bar\n")
      result = input.with_validators(custom_provider).validate(:custom_check).run

      expect(result).to eq('foo@bar')
      expect(writer.string).to include('must contain @')
    end
  end

  describe '#convert_func' do
    context 'with a block converter' do
      it 'converts the input value' do
        input, = build_input("42\n")
        result = input.convert_func { |val| val.to_i }.run

        expect(result).to eq(42)
      end

      it 'converts to uppercase' do
        input, = build_input("hello\n")
        result = input.convert_func { |val| val.upcase }.run

        expect(result).to eq('HELLO')
      end
    end

    context 'with a Proc converter' do
      it 'converts using the proc' do
        converter = proc { |val| val.to_i * 2 }
        input, = build_input("21\n")
        result = input.convert_func(converter).run

        expect(result).to eq(42)
      end
    end

    context 'with validation and conversion' do
      it 'validates before converting' do
        input, writer = build_input("abc\n42\n")
        result = input
                 .validate { |val| val.match?(/^\d+$/) ? nil : 'Must be a number' }
                 .convert_func { |val| val.to_i }
                 .run

        expect(result).to eq(42)
        expect(writer.string).to include('Must be a number')
      end
    end

    context 'without converter' do
      it 'returns the string as-is' do
        input, = build_input("hello\n")
        result = input.run

        expect(result).to eq('hello')
      end
    end

    context 'when conversion raises an exception' do
      it 'shows error message and prompts user to add validation' do
        input, writer = build_input("abc\n42\n")
        result = input.convert_func { |val| Integer(val) }.run

        expect(result).to eq(42)
        output = writer.string
        expect(output).to include('Conversion error')
        expect(output).to include('please add validation')
      end

      it 're-prompts after conversion error' do
        input, writer = build_input("not_a_number\n123\n")
        result = input.convert_func { |val| Integer(val) }.run

        expect(result).to eq(123)
        expect(writer.string).to include('Conversion error')
      end
    end
  end

  describe 'method chaining' do
    it 'supports fluent API' do
      input, = build_input("test\n")
      result = input
               .title('Title')
               .prompt('>> ')
               .validate { |val| val.empty? ? 'required' : nil }
               .run

      expect(result).to eq('test')
    end

    it 'supports chaining with convert_func' do
      input, = build_input("123\n")
      result = input
               .title('Enter a number')
               .validate(:not_empty)
               .convert_func { |val| val.to_i }
               .run

      expect(result).to eq(123)
    end
  end
end
