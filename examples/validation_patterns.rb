# frozen_string_literal: true

require_relative '../input'

puts "=== Validation Patterns Example ===\n\n"

# Pattern 1: Email validation
email = Input.new_input
             .title('Enter your email address')
             .prompt('email> ')
             .validate(:not_empty)
             .validate { |val| val.match?(/\A[^@\s]+@[^@\s]+\.[^@\s]+\z/) ? nil : 'Invalid email format' }
             .run

puts "Email registered: #{email}\n\n"

# Pattern 2: Password with multiple rules
password = Input.new_input
                .title('Create a secure password')
                .prompt('password> ')
                .validate(:not_empty)
                .validate { |val| val.length >= 8 ? nil : 'Must be at least 8 characters' }
                .validate { |val| val.match?(/[A-Z]/) ? nil : 'Must contain at least one uppercase letter' }
                .validate { |val| val.match?(/[0-9]/) ? nil : 'Must contain at least one number' }
                .run

puts "Password created! (#{password.length} characters)\n\n"

# Pattern 3: Range validation with conversion
age = Input.new_input
           .title('Enter your age')
           .prompt('age> ')
           .validate(:not_empty)
           .validate { |val| val.match?(/^\d+$/) ? nil : 'Must be a number' }
           .validate { |val| val.to_i.between?(1, 120) ? nil : 'Age must be between 1 and 120' }
           .convert_func { |val| val.to_i }
           .run

puts "Age: #{age} (type: #{age.class})\n\n"

# Pattern 4: Choice validation
choice = Input.new_input
              .title('Select your preferred language')
              .prompt('(ruby/python/javascript)> ')
              .validate(:not_empty)
              .validate { |val| %w[ruby python javascript].include?(val.downcase) ? nil : 'Must be ruby, python, or javascript' }
              .convert_func { |val| val.downcase.to_sym }
              .run

puts "Selected language: #{choice} (type: #{choice.class})"
