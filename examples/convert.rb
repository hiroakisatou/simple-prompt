# frozen_string_literal: true

require_relative '../input'

# Convert string to integer with proper validation
# Validation prevents conversion errors
age = Input.new_input
           .title('How old are you?')
           .prompt('age> ')
           .validate(:not_empty)
           .validate { |val| val.match?(/^\d+$/) ? nil : 'Please enter a valid number' }
           .convert_func { |val| val.to_i }
           .run

puts "You are #{age} years old (type: #{age.class})"

# Example: Without validation, conversion can fail
# This will show an error message prompting you to add validation
puts "\n--- Example of conversion error (try entering 'abc') ---"
number = Input.new_input
              .title('Enter a number (without validation)')
              .prompt('> ')
              .convert_func { |val| Integer(val) } # Integer() raises exception on invalid input
              .run

puts "Number: #{number}"

# Convert to uppercase
name = Input.new_input
            .title('What is your name?')
            .prompt('name> ')
            .validate(:not_empty)
            .convert_func { |val| val.upcase }
            .run

puts "Hello, #{name}!"

# Convert to array by splitting
tags = Input.new_input
            .title('Enter tags (comma-separated)')
            .prompt('tags> ')
            .validate(:not_empty)
            .convert_func { |val| val.split(',').map(&:strip) }
            .run

puts "Tags: #{tags.inspect} (type: #{tags.class})"

# Using Proc instead of block
to_float = proc { |val| val.to_f }
price = Input.new_input
             .title('Enter price')
             .prompt('$')
             .validate(:not_empty)
             .validate { |val| val.match?(/^\d+\.?\d*$/) ? nil : 'Please enter a valid price' }
             .convert_func(to_float)
             .run

puts "Price: $#{price} (type: #{price.class})"
