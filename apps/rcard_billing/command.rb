require_relative "../../libs/logger"
require_relative "../../libs/rakutencard/client"
require_relative "../../libs/mygoogledrive/session"
require_relative "../../libs/linebot/client"
require_relative "../../libs/linebot/helpers"

module RCardBilling
  class Command

    def initialize
      @config = YAML.load_file("credentials/credentials.yaml")
      # TODO : Yaml 読み込み周りのリファクタ
      @rcard_client = RakutenCard::Client.new(@config["rakuten"]["username"], @config["rakuten"]["password"])
      
      @upload_dest_id = @config["googledrive"]["root_collection_id"]
      @gdrive_session = MyGoogleDrive.new_session(@config["googledrive"]["client_id"], @config["googledrive"]["client_secret"], @config["googledrive"]["refresh_token"])
      
      @notify_to = @config["line"]["notify_to"]
      @line_client = LineBot.new_client(@config["line"]["channel_id"], @config["line"]["channel_secret"], @config["line"]["channel_token"])
    end

    def save_billing_of(year, month)
      Logger.info("Saving billing statement of #{year}/#{month}")
      saved_file = @rcard_client.save_billing(year, month)
      Logger.info("Billing statement saved to '#{saved_file}'")

      uploaded = upload_file(upload_dest_id, saved_file, year)
      Logger.info("#{uploaded.title} uploaded to Google Drive.")

      message = """
        #{year}年 #{month}月 の 楽天カード請求明細です！
        #{uploaded.human_url}
      """
      notify(@notify_to, message)
    end

    def save_billing_between(from, to)
      if from > to
        raise "From date must before to date. From:#{from.strftime("%Y-%m")}, To:#{to.strftime("%Y-%m")}"
      end

      Logger.info("Fetch loop for #{from.strftime("%Y-%m")} to #{to.strftime("%Y-%m")}.")
      while from <= to
        save_billing_of(from.year, from.month)
        from = from.next_month
      end
    end

    private

    def upload_file(upload_dest_id, filepath, year)
      upload_dest = @gdrive_session.collection_by_id(upload_dest_id)
      year_folder = upload_dest.subcollection_by_title("#{year}")
      if year_folder.nil?
        year_folder = upload_dest.create_subcollection("#{year}")
      end
      # Google Drive では、同じフォルダ配下に同じ名前のファイルが作成できてしまうので、
      # ファイル名 で 検索してすでにアップロード済みであればスキップする。
      filename = File.basename(filepath)
      found = year_folder.file_by_title(filename)
      if found.nil?
        # デフォルトは、convert: true だが、変換されると拡張子が消されてしまうため、
        # 前段のファイル名チェックで検索できなくなるので、convert: false にする。
        year_folder.upload_from_file(filepath, filename, convert: false)
      else
        Logger.info("[SKIPPED] File named '#{filename}' was already on Google Drive.")
        found
      end
    end

    def notify(notify_to, message) 
      body = LineBot::Helpers::BodyBuilder.new.text(message).random_sticker.body
      @line_client.push_message(notify_to, body)
    end
  end
end