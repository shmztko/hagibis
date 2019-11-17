require 'line/bot'

module LineBot

  def self.new_client(channel_id, channel_secret, channel_token)
    Line::Bot::Client.new do |config|
      config.channel_id = channel_id
      config.channel_secret = channel_secret
      config.channel_token = channel_token
    end
  end

  def broadcast(message)
    body = LineBot::BodyBuilder.new.text(message).random_sticker().body
    client.broadcast(body)
  end

  def push_message(to, message)
    body = LineBot::BodyBuilder.new.text(message).random_sticker().body
    client.push_message(to, body)
  end
end