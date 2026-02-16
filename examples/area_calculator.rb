#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/simple_prompt'

# Example: Area Calculator with Input Validation and Conversion
# This example demonstrates using Input with:
# - Custom validation for positive numbers
# - Value conversion from string to integer/float
# - Reusable conversion function

class AreaCalculator
  def initialize(reader = $stdin, writer = $stdout)
    @reader = reader
    @writer = writer
  end

  # Conversion function that converts string to appropriate numeric type
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
    @writer.puts "The area is"
    @writer.puts "#{area} square feet"
    @writer.puts "#{(area * 0.09290304).round(3)} square meters"
  end
end

# Run the calculator if this file is executed directly
if __FILE__ == $PROGRAM_NAME
  calculator = AreaCalculator.new
  calculator.calculate_area
end
