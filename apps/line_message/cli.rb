require "thor"
require_relative "./command"
module LineMessage
  class CLI < Thor

    desc "push MESSAGE", "Send message via LINE BOT"
    def push(message)
      command = LineMessage::Command.new
      command.push_message(message)
    end

    def self.banner(task, namespace = false, subcommand = true)
      super
    end
  end  
end
