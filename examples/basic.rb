# frozen_string_literal: true

require_relative '../input'

# Basic usage - simple text input
name = Input.new_input
            .title('What is your name?')
            .prompt('> ')
            .validate(:not_empty)
            .run

puts "Hello, #{name}!"

# With custom validation
email = Input.new_input
             .title('Enter your email')
             .prompt('email> ')
             .validate { |val| val.include?('@') ? nil : 'Please enter a valid email' }
             .run

puts "Your email: #{email}"

# Multiple validators
password = Input.new_input
                .title('Create a password')
                .prompt('password> ')
                .validate(:not_empty)
                .validate { |val| val.length < 8 ? 'Password must be at least 8 characters' : nil }
                .run

puts "Password set! (#{password.length} characters)"
