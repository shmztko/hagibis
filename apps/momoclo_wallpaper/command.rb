require_relative "../../libs/logger"
require_relative "../../libs/momoclo/client"

module MomocloWallpaper
  class Command

    def initialize
      @config = YAML.load_file("credentials/credentials.yaml")
      @momoclo_client = Momoclo::Client.new(@config["angeleyes"]["id"], @config["angeleyes"]["password"])
      @gdrive_client = MyGoogleDrive::Client.new(@config["googledrive"]["client_id"], @config["googledrive"]["client_secret"], @config["googledrive"]["refresh_token"])
      @save_to = @config["momoclo_wallpaper"]["save_to"]
    end

    def save(year, month)
      Logger.info("Saving momoclo fc wallpaper of #{year}/#{month}")
      saved_files = @momoclo_client.save_wallpapers(year, month)
      Logger.info("momoclo fc wallpaper was saved to #{saved_files}.")

      upload_root = @gdrive_client.session.collection_by_id(@save_to)
      saved_files.each do |file|
        uploaded = @gdrive_client.upload_file_with_subdir(upload_root, file, year)
        Logger.info("#{uploaded.title} uploaded to Google Drive.")
      end
    end

    def save_between(from, to)
      if from > to
        raise "From date must before to date. From:#{from.strftime("%Y-%m")}, To:#{to.strftime("%Y-%m")}"
      end

      Logger.info("Fetch loop for #{from.strftime("%Y-%m")} to #{to.strftime("%Y-%m")}.")
      while from <= to
        save(from.year, from.month)
        from = from.next_month
      end
    end

  end
end