# frozen_string_literal: true

require 'logger'

# このアプリケーション用のロガー
class Logger
  LOGGER = Logger.new('logs/hagibis.log')

  class << self
    def info(message)
      LOGGER.info(message)
    end
  end
end
