require_relative '../../libs/logger'
require_relative '../../libs/errors'
require_relative '../../libs/rakutencard/enav_parser'
require_relative '../../libs/rakutencard/billing_csv_parser'
require_relative '../../libs/mygoogledrive/client'
require_relative '../../libs/linebot/client'
require_relative '../../libs/linebot/helpers'

module RCardBilling
  # 楽天カードの請求書を扱うクラス。
  class Command

    # 楽天カードの請求書を保存 / 通知するCommandクラスを生成します。
    def initialize
      @config = YAML.load_file('credentials/credentials.yaml')
      # FIXME : Yaml 読み込み周りのリファクタ

      # 楽天会員設定読み込み
      rakuten_config = @config['rakuten']
      @enav_parser = RakutenCard::EnavParser.new(
        rakuten_config['username'],
        rakuten_config['password']
      )

      # GoogleDrive設定読み込み
      gdrive_config = @config['googledrive']
      @upload_dest_id = gdrive_config['root_collection_id']
      @gdrive_client = MyGoogleDrive::Client.new(
        gdrive_config['client_id'],
        gdrive_config['client_secret'],
        gdrive_config['refresh_token']
      )

      # LINE通知設定読み込み
      line_config = @config['line']
      @notify_to = line_config['notify_to']
      @line_client = LineBot.new_client(
        line_config['channel_id'],
        line_config['channel_secret'],
        line_config['channel_token']
      )
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

      return unless notify

      total_billing_amount = RakutenCard::BillingCsvParser.new(saved_file).total_billing_amount

      message = <<-MSG
        [#{year}年 #{month}月]
        楽天カード請求通知です！

        今月の請求金額は #{total_billing_amount.to_s(:delimited)} 円です。

        請求明細はこちら↓
        #{uploaded.human_url}
      MSG
      body = LineBot::Helpers::BodyBuilder.new
                                          .text(message.strip.gsub(' ', ''))
                                          .random_sticker
                                          .body
      @line_client.push_message(@notify_to, body)
    end

    # 指定された年月の楽天カードの請求書を保存する。
    # from <= x <= to の期間の請求書を保存する。
    # @param [Time] from 請求書保存対象の開始年月
    # @param [Time] to 請求書保存対象の終了年月
    def save_between(from, to)
      if from > to
        msg = "From date must before to date. From:#{from.strftime('%Y-%m')}, To:#{to.strftime('%Y-%m')}"
        raise Errors::HagibisError, msg
      end

      Logger.info("Fetch loop for #{from.strftime('%Y-%m')} to #{to.strftime('%Y-%m')}.")
      while from <= to
        save(from.year, from.month, notify: false)
        from = from.next_month
      end
    end
  end
end
