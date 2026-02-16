# typed: strict
# frozen_string_literal: true

require 'sorbet-runtime'

# 1. デフォルトバリデーター
module DefaultValidators
  extend T::Sig

  module_function

  sig { params(val: String).returns(T.nilable(String)) }
  def not_empty(val); val.empty? ? '入力してください' : nil; end
end
