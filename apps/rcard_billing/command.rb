require_relative "../../libs/logger"
require_relative "../../libs/rakutencard/client"
require_relative "../../libs/mygoogledrive/client"
require_relative "../../libs/linebot/client"
require_relative "../../libs/linebot/helpers"

module RCardBilling
  class Command

    def initialize
      @config = YAML.load_file("credentials/credentials.yaml")
      # TODO : Yaml 読み込み周りのリファクタ
      @rcard_client = RakutenCard::Client.new(@config["rakuten"]["username"], @config["rakuten"]["password"])
      
      @upload_dest_id = @config["googledrive"]["root_collection_id"]
      @gdrive_client = MyGoogleDrive::Client.new(@config["googledrive"]["client_id"], @config["googledrive"]["client_secret"], @config["googledrive"]["refresh_token"])
      
      @notify_to = @config["line"]["notify_to"]
      @line_client = LineBot.new_client(@config["line"]["channel_id"], @config["line"]["channel_secret"], @config["line"]["channel_token"])
    end

    def save(year, month, notify: true)
      Logger.info("Saving billing statement of #{year}/#{month}")
      saved_file = @rcard_client.save_billing(year, month)
      Logger.info("Billing statement saved to '#{saved_file}'")

      upload_root = @gdrive_client.session.collection_by_id(@upload_dest_id)
      uploaded = @gdrive_client.upload_file_with_subdir(upload_root, saved_file, year)
      Logger.info("#{uploaded.title} uploaded to Google Drive.")

      if notify
        message = """
          #{year}年 #{month}月 の 楽天カード請求明細です！
          #{uploaded.human_url}
        """
        body = LineBot::Helpers::BodyBuilder.new.text(message).random_sticker.body
        @line_client.push_message(notify_to, body)
      end
    end

    def save_between(from, to)
      if from > to
        raise "From date must before to date. From:#{from.strftime("%Y-%m")}, To:#{to.strftime("%Y-%m")}"
      end

      Logger.info("Fetch loop for #{from.strftime("%Y-%m")} to #{to.strftime("%Y-%m")}.")
      while from <= to
        save(from.year, from.month, notify: false)
        from = from.next_month
      end
    end
  end
end