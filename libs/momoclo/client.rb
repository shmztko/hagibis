require "mechanize"
require_relative "../logger"
module Momoclo
  class Client

    SAVE_DIR = "./data/"

    def initialize(fanclub_id, password)
      @client = Mechanize.new
      @fanclub_id = fanclub_id
      @password = password
    end

    def authenticate
      login_page = @client.get('https://fc.momoclo.net/pc/login.php')
      login_page.form_with(id: 'loginForm') do |form|
        form.login_id = @fanclub_id
        form.password = @password
      end.submit
    end

    def save_wallpapers(year, month)
      authenticate

      saved_files = []
      get_wallpaper_links(year, month).each do |link|
        image = @client.get(link)
        saved_filepath = File.join(SAVE_DIR, "#{year}#{pad_month(month)}_#{image.filename}")
        image.save_as(saved_filepath)
        saved_files << saved_filepath
      end
      saved_files
    end

    private

    def get_wallpaper_links(year, month)
      download_page = @client.get("https://fc.momoclo.net/pc/download/")
      links = download_page.search(".downloadList .imgR p > a") \
        .map {|e| e.attributes["href"].value } \
        .select {|v| v =~ /^.+\/#{year}#{pad_month(month)}\/.+$/}

      Logger.info("Link for momoclo wallpapers are #{links}.")
      if links.empty?
        raise "Links for momoclo wallpaper not found for #{year}/#{pad_month(month)}."
      end
      links
    end

    def pad_month(month)
      month.to_s.rjust(2, "0")
    end
  end
end

