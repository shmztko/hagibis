# frozen_string_literal: true

module Errors
  # Hagibis アプリケーションの基底例外
  # アプリケーションでハンドリングする例外は全部これ or これを継承した例外にする
  class HagibisError < StandardError; end
end
