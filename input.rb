# typed: strict
# frozen_string_literal: true

require 'sorbet-runtime'
require 'stringio'

# 1. デフォルトバリデーター
module DefaultValidators
  extend T::Sig

  module_function

  sig { params(val: String).returns(T.nilable(String)) }
  def not_empty(val); val.empty? ? 'Input is required' : nil; end
end

# 2. 本体
class Input
  extend T::Sig

  ValidatorProc = T.type_alias { T.proc.params(arg0: String).returns(T.nilable(String)) }
  ValidatorType = T.type_alias { T.any(Symbol, ValidatorProc) }
  ConvertProc = T.type_alias { T.proc.params(arg0: String).returns(T.untyped) }

  sig { returns(Input) }
  def self.new_input; new; end

  private_class_method :new

  sig { void }
  def initialize
    @reader = T.let($stdin, T.any(IO, StringIO))
    @writer = T.let($stdout, T.any(IO, StringIO))
    @title = T.let('', String)
    @prompt = T.let('> ', String)
    @validators = T.let([], T::Array[ValidatorProc])
    @validator_provider = T.let(DefaultValidators, T.untyped)
    @convert_func = T.let(nil, T.nilable(ConvertProc))
  end

  sig { params(text: String).returns(T.self_type) }
  def title(text); @title = text; self; end

  sig { params(text: String).returns(T.self_type) }
  def prompt(text); @prompt = text; self; end

  sig { params(provider: T.untyped).returns(T.self_type) }
  def with_validators(provider); @validator_provider = provider; self; end

  sig { params(validator: T.nilable(ValidatorType), block: T.nilable(ValidatorProc)).returns(T.self_type) }
  def validate(validator = nil, &block)
    if block
      @validators << block
    elsif validator.is_a?(Proc)
      @validators << validator
    elsif validator.is_a?(Symbol)
      unless @validator_provider.respond_to?(validator)
        raise ArgumentError, "Unknown validator :#{validator} in #{@validator_provider}"
      end

      @validators << @validator_provider.method(validator).to_proc
    end
    self
  end

  sig { params(converter: T.nilable(ConvertProc), block: T.nilable(ConvertProc)).returns(T.self_type) }
  def convert_func(converter = nil, &block)
    @convert_func = block || converter
    self
  end

  sig { returns(T.untyped) }
  def run
    loop do
      @writer.puts "\e[1m#{@title}\e[0m" unless @title.empty?
      @writer.print @prompt

      input_data = @reader.gets
      return '' if input_data.nil? # Ctrl-D

      val = input_data.chomp.strip
      error = T.let(nil, T.nilable(String))
      @validators.each { |v| break if (error = v.call(val)) }

      unless error
        begin
          return @convert_func ? @convert_func.call(val) : val
        rescue StandardError => e
          error = "Conversion error: #{e.message} (please add validation)"
        end
      end

      # 視認性のための余白
      @writer.puts ''
      @writer.puts "\e[31m! #{error}\e[0m"
      @writer.puts ''
    end
  rescue Interrupt # Ctrl-C
    @writer.puts "\n\e[2m(canceled)\e[0m"
    exit 0
  end

  private

  sig { params(r: T.any(IO, StringIO), w: T.any(IO, StringIO)).returns(T.self_type) }
  def with_context(r, w); @reader = r; @writer = w; self; end
end
