# frozen_string_literal: true

require_relative '../lib/simple_prompt'
require_relative 'area_calculator'

# Example RSpec tests for area_calculator.rb
# This demonstrates how to test Input with mocks

RSpec.describe AreaCalculator do
  let(:writer) { double('writer') }
  let(:reader) { double('reader') }
  subject(:calculator) { AreaCalculator.new(reader, writer) }

  before do
    allow(writer).to receive(:puts)
    allow(writer).to receive(:print)
  end

  describe '#input_length' do
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

  describe '#input_width' do
    it 'returns integer for valid integer input' do
      allow(reader).to receive(:gets).and_return("20\n")

      result = calculator.input_width

      expect(result).to eq(20)
    end

    it 'returns float for valid float input' do
      allow(reader).to receive(:gets).and_return("20.3\n")

      result = calculator.input_width

      expect(result).to eq(20.3)
    end
  end
end
