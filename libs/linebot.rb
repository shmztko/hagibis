require 'line/bot'

module LineBot

  STICKER_POOL = [
    "52002734",
    "52002735",
    "52002763",
    "52002771",
    "52002748",
    "52002768",
    "52002753" 
  ].freeze

  class Client
    def initialize(config)
      @config = config["line"]
      @client = Line::Bot::Client.new do |config|
        config.channel_id = @config["channel_id"]
        config.channel_secret = @config["channel_secret"]
        config.channel_token = @config["channel_token"]
      end
      @user_id = @config["bot_user_id"]
    end

    def push_message(message)
      body = [
        {
          type: 'text',
          text: message
        },
        {
          type: 'sticker',
          packageId: '11537',
          stickerId: STICKER_POOL[rand(7)]
        }
      ]
      @client.push_message(@user_id, body)
    end
  end
end