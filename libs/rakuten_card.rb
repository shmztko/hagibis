require 'date'
require 'mechanize'
require 'time_difference'

module RakutenCard

    HOST_NAME = "https://www.rakuten-card.co.jp"
    ENAVI_PATH = "/e-navi/members/statement/index.xhtml"
    LOGOUT_PATH = "/e-navi/members/pre-logout.xhtml?l-id=enavi_all_header_logout"

    class Client
        def initialize config
            @client = Mechanize.new
            @config = config["rakuten"]

        end

        def authenticate
            login_page = @client.get("#{HOST_NAME}#{ENAVI_PATH}", {tabNo: 1})
            # ログアウトのボタンが存在していれば認証済みと判断
            if not login_page.link_with(href: LOGOUT_PATH).nil?
                true
            else
                login_page.form_with(:id => 'indexForm') do |form|
                    form['u'] = @config["username"]
                    form['p'] = @config["password"]
                end.submit
                true
            end
        end

        def download_csv(target_year, target_month)
            validator = Validator.new(target_year, target_month)
            if validator.is_future?
                raise "Given date can not be a future date. #{target_year}/#{target_month}"
            end
            if validator.retention_period_exceeded?
                raise "Cannot download billing statement over retention limit. #{target_year}/#{target_month}"
            end

            authenticate

            tab_number = TabResolver.get_tab_index(target_year, target_month)
            Logger.info("Tab number resolved from date was #{tab_number}.")

            usage_detail_csv = @client.get("#{HOST_NAME}#{ENAVI_PATH}", {tabNo: tab_number, downloadAsCsv: 1})

            download_path = "./data/#{usage_detail_csv.filename}"
            File.open(download_path,"w") do |f|
                f.puts(usage_detail_csv.content.encode("UTF-8", "Shift_JIS"))
            end
            download_path
        end
    end

    class Validator
        def initialize(target_year, target_month)
            @given = Time.local(target_year, target_month)
            @current = Time.local(Time.now.year, Time.now.month)
        end

        def is_future?
            @given > @current
        end

        def retention_period_exceeded?
            # 楽天カードの明細は、13ヶ月前までしか閲覧できない。
            TimeDifference.between(@given, @current).in_months > 13
        end
    end

    class TabResolver
        def self.get_tab_index(target_year, target_month)
            first_day_of_current_month = Time.local(Time.now.year, Time.now.month)
            first_day_of_target_month = Time.local(target_year, target_month)
            if first_day_of_current_month - first_day_of_target_month < 0
                raise "Can't get tab index for future date. year : #{target_year}, month : #{target_month}"
            end
            # NOTES : Need to +1 after calculate difference of two dates.
            #         According to following specification.
            # ====================================================
            # Specification of tab number for Rakuten E-navi page
            # payment detail for next month : tab number = 0
            # payment detail for current month : tab number = 1
            # payment detail for previous month : tab number = 2
            # ====================================================
            # Example.
            # Today : 2019-10-13
            # Tab Number = 0 : Payment detail for 2019-11
            # Tab Number = 1 : Payment detail for 2019-10
            # Tab Number = 2 : Payment detail for 2019-09
            TimeDifference.between(first_day_of_current_month, first_day_of_target_month).in_months.round + 1
        end
    end
end
