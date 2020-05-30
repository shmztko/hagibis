require "mechanize"
require "nkf"
require_relative "./helpers"

module RakutenCard
  module URL
    HOST_NAME = "https://www.rakuten-card.co.jp"
    ENAVI_PATH = "/e-navi/members/statement/index.xhtml"
    LOGOUT_PATH = "/e-navi/members/pre-logout.xhtml?l-id=enavi_all_header_logout"

    def self.enavi_url
      "#{RakutenCard::URL::HOST_NAME}#{RakutenCard::URL::ENAVI_PATH}"
    end
  end

  class EnavParser

    SAVE_DIR = "./data/"

    # @param [String] username 楽天e-naviのユーザID
    # @param [String] password 楽天e-naviのパスワード 
    def initialize(username, password)
      @client = Mechanize.new
      @username = username
      @password = password
    end

    # 楽天カード e-navi へログインする。
    # @return [true,false] 認証に成功した場合 : true, 失敗した場合 : false
    def authenticate
      login_page = @client.get(RakutenCard::URL.enavi_url, {tabNo: 1})
      # ログアウトのボタンが存在していれば認証済みと判断
      if not login_page.link_with(href: RakutenCard::URL::LOGOUT_PATH).nil?
        true
      else
        login_page.form_with(:id => 'indexForm') do |form|
          form['u'] = @username
          form['p'] = @password
        end.submit
        true
      end
      false
    end

    # 楽天カードの請求書を保存する。
    # @param [String] target_year  何年の請求書を保存するか？ ex) 2019年の場合 : 2019
    # @param [String] target_month 何月の請求書を保存するか？ ex) ９月の場合 : 9
    # @return [String] 保存したファイルのファイルパス
    def save_billing(target_year, target_month)
      validator = RakutenCard::Validator.new(target_year, target_month)
      if validator.is_future?
        raise "Date for saving billing cann't be a future date. #{target_year}/#{target_month}"
      end
      if validator.retention_period_exceeded?
        raise "Cannot save billing over retention limit. #{target_year}/#{target_month}"
      end

      authenticate

      tab_number = RakutenCard::TabResolver.get_tab_index(target_year, target_month)
      Logger.info("Tab number resolved from date was #{tab_number}.")

      billing_csv = @client.get(RakutenCard::URL.enavi_url, {tabNo: tab_number, downloadAsCsv: 1})

      save_to = File.join(SAVE_DIR, billing_csv.filename)

      # e-navi でダウンロードできるファイルはS-JISなので、扱いやすいようにUTF-8 にして保存する。
      File.open(save_to, "w") do |f|
        f.puts(NKF.nkf("-w", billing_csv.content))
      end
      save_to
    end
  end
end
