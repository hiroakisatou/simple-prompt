# frozen_string_literal: true

require_relative '../input'

puts "=== Error Handling Example ===\n\n"

# Example 1: Conversion without validation (will show error on invalid input)
puts "Try entering 'abc' to see the error message:"
number = Input.new_input
              .title('Enter a number (no validation)')
              .prompt('> ')
              .convert_func { |val| Integer(val) }
              .run

puts "Number: #{number}\n\n"

# Example 2: Proper validation before conversion
puts "Now with validation:"
safe_number = Input.new_input
                   .title('Enter a number (with validation)')
                   .prompt('> ')
                   .validate(:not_empty)
                   .validate { |val| val.match?(/^-?\d+$/) ? nil : 'Must be a valid integer' }
                   .convert_func { |val| val.to_i }
                   .run

puts "Number: #{safe_number}\n\n"

# Example 3: Float conversion with validation
price = Input.new_input
             .title('Enter price')
             .prompt('$')
             .validate(:not_empty)
             .validate { |val| val.match?(/^\d+\.?\d*$/) ? nil : 'Must be a valid price (e.g., 10 or 10.99)' }
             .convert_func { |val| val.to_f }
             .run

puts "Price: $#{format('%.2f', price)}"
