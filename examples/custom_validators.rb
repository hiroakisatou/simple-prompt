# frozen_string_literal: true

require 'simple_prompt'

# Define a custom validator provider
module MyValidators
  module_function

  def email(val)
    val.match?(/\A[^@\s]+@[^@\s]+\z/) ? nil : 'Invalid email format'
  end

  def min_length(val)
    val.length >= 3 ? nil : 'Must be at least 3 characters'
  end
end

# Use with_validators to swap in your custom provider
username = Input.new_input
                .title('Choose a username')
                .prompt('>> ')
                .with_validators(MyValidators)
                .validate(:min_length)
                .run

puts "Username: #{username}"

email = Input.new_input
             .title('Enter your email')
             .prompt('>> ')
             .with_validators(MyValidators)
             .validate(:email)
             .run

puts "Email: #{email}"
