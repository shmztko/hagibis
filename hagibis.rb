#!/usr/bin/ruby
Dir[File.expand_path("../libs/", __FILE__) << '/*.rb'].each{|file| require file }
require 'thor'
require 'yaml'
require 'date'

module Hagibis

  class Command
    def initialize
      @config = YAML.load_file("config/credentials.yaml")
      @rcard_client = RakutenCard::Client.new(@config)
      @gdrive_client = MyGoogleDrive::Client.new(@config)
      @line_client = LineBot::Client.new(@config)
    end

    def save(year, month)
      Logger.info("Saving billing statement of #{year}/#{month}")

      file_path = @rcard_client.download_csv(year, month)
      Logger.info("Billing statement downloaded to '#{file_path}'")

      uploaded = @gdrive_client.upload_file(file_path, year)
      Logger.info("#{uploaded.title} uploaded.")

      msg = """#{year}年 #{month}月 の 楽天カード請求明細です！\n#{uploaded.human_url}"""
      @line_client.push_message(msg)
    end

    def bulk_save(from, to)
      raise "From date must before to date. From:#{from.strftime("%Y-%m")}, To:#{to.strftime("%Y-%m")}" if from > to

      Logger.info("Fetch loop for #{from.strftime("%Y-%m")} to #{to.strftime("%Y-%m")}.")
      while from <= to
        save(from.year, from.month)
        from = from.next_month
      end
    end
  end

  class CLI < Thor

    desc "save_between FROM_YEAR FROM_MONTH TO_YEAR TO_MONTH", "Save billing statement between given year/month."
    def save_between(from_year, from_month, to_year, to_month)
      from = Time.local(from_year, from_month)
      to = Time.local(to_year, to_month)

      command = Hagibis::Command.new
      command.bulk_save(from, to)
    end

    desc "save_from FROM_YEAR FROM_MONTH", "Save billing statement from given year/month to current year/month."
    def save_from(from_year, from_month)
      from = Time.local(from_year, from_month)
      to = Time.local(Time.now.year, Time.now.month)

      command = Hagibis::Command.new
      command.bulk_save(from, to)
    end

    desc "save YEAR MONTH", "Save billing statement of given year/month."
    def save(year, month)
      command = Hagibis::Command.new
      command.save(year, month)
    end
  end
end
if __FILE__ == $0
  Hagibis::CLI.start(ARGV)
end
