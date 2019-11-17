require_relative "../../libs/logger"
require_relative "../../libs/linebot/client"
require_relative "../../libs/linebot/helpers"

module LineMessage
  class Command

    def initialize
      @config = YAML.load_file("credentials/credentials.yaml")
      @notify_to = @config["line"]["notify_to"]
      @line_client = LineBot.new_client(@config["line"]["channel_id"], @config["line"]["channel_secret"], @config["line"]["channel_token"])
    end

    def push_message(message)
      body = body = LineBot::Helpers::BodyBuilder.new.text(message).random_sticker.body
      @line_client.push_message(@notify_to, body)
    end
  end
end