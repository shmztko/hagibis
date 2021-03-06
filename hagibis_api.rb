require 'sinatra/base'
require 'logger'
require 'line/bot'
require 'yaml'

class HagibisApi < Sinatra::Base
  logger = Logger.new(STDOUT)

  set :bind, '0.0.0.0'

  def config
    @config ||= YAML.load_file("credentials/credentials.yaml")
  end

  def client
    @client ||= Line::Bot::Client.new do |c|
      c.channel_id = config["line"]["channel_id"]
      c.channel_secret = config["line"]["channel_secret"]
      c.channel_token = config["line"]["channel_token"]
    end
  end

  get '/' do
    logger.info 'ok'
    "Hello world"
  end

  post '/callback' do
    body = request.body.read

    logger.info(body)

    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      logger.error("Signature validation failed")
      error 400 do 'Bad Request' end
    end

    # 返事来るのうざいので return
    return "OK"

    events = client.parse_events_from(body)
    events.each { |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          message = {
            type: 'text',
            text: event.message['text']
          }
          client.reply_message(event['replyToken'], message)
        when Line::Bot::Event::MessageType::Image, Line::Bot::Event::MessageType::Video
          response = client.get_message_content(event.message['id'])
          tf = Tempfile.open("content")
          tf.write(response.body)
        end
      end
    }
    "OK"
  end
end
