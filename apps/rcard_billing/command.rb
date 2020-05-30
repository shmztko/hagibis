require_relative "../../libs/logger"
require_relative "../../libs/rakutencard/enav_parser"
require_relative "../../libs/mygoogledrive/client"
require_relative "../../libs/linebot/client"
require_relative "../../libs/linebot/helpers"

module RCardBilling
  class Command

    # 楽天カードの請求書を保存 / 通知するCommandクラスを生成します。
    def initialize
      @config = YAML.load_file("credentials/credentials.yaml")
      # FIXME : Yaml 読み込み周りのリファクタ
      @enav_parser = RakutenCard::EnavParser.new(@config["rakuten"]["username"], @config["rakuten"]["password"])
      
      @upload_dest_id = @config["googledrive"]["root_collection_id"]
      @gdrive_client = MyGoogleDrive::Client.new(@config["googledrive"]["client_id"], @config["googledrive"]["client_secret"], @config["googledrive"]["refresh_token"])
      
      @notify_to = @config["line"]["notify_to"]
      @line_client = LineBot.new_client(@config["line"]["channel_id"], @config["line"]["channel_secret"], @config["line"]["channel_token"])
    end

    # 指定された年月の楽天カードの請求書を保存する。
    # @param [Integer] year 請求書保存対象の 年
    # @param [Integer] month 請求書保存対象の 月
    # @param [Boolean] notify 楽天カードからの請求情報を通知するか。true : 通知する, false : 通知しない
    def save(year, month, notify: true)
      Logger.info("Saving billing statement of #{year}/#{month}")
      saved_file = @enav_parser.save_billing(year, month)
      Logger.info("Billing statement saved to '#{saved_file}'")

      upload_root = @gdrive_client.session.collection_by_id(@upload_dest_id)
      uploaded = @gdrive_client.upload_file_with_subdir(upload_root, saved_file, year)
      Logger.info("#{uploaded.title} uploaded to Google Drive.")

      if notify
        message = """
          #{year}年 #{month}月 の 楽天カード請求明細です！
          #{uploaded.human_url}
        """.strip.gsub(" ", "")
        body = LineBot::Helpers::BodyBuilder.new.text(message).random_sticker.body
        @line_client.push_message(@notify_to, body)
      end
    end

    # 指定された年月の楽天カードの請求書を保存する。
    # from <= x <= to の期間の請求書を保存する。
    # @param [Time] from 請求書保存対象の開始年月
    # @param [Time] to 請求書保存対象の終了年月
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