require 'logger'
class Logger
    LOGGER = Logger.new("logs/hagibis.log")

    class << self
        def info(message)
            LOGGER.info(message)
        end
    end
end