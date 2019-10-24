require 'google_drive'
module MyGoogleDrive

  class Client

    def initialize(config)
      @config = config["googledrive"]
      @session = GoogleDrive::Session.from_config(Config.get(@config))
      @upload_root = @session.collection_by_id(@config["root_collection_id"])
    end

    def upload_file(filepath, year)
      year_folder = @upload_root.subcollection_by_title("#{year}")
      if year_folder.nil?
        year_folder = @upload_root.create_subcollection("#{year}")
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
      # p "Files after upload completed =====."
      # year_folder.files.each do |file|
      #   p file.title
      # end
      # p "===================="
    end
  end

  # Session#from_config へ渡す config は、指定されたメソッドを実装しているカスタムクラスでも可。
  # Ref : https://www.rubydoc.info/gems/google_drive/GoogleDrive%2FSession.from_config
  class Config

    def self.get(config)
      Config.new(config["client_id"], config["client_secret"], config["refresh_token"])
    end

    DEFAULT_SCOPE = [
      'https://www.googleapis.com/auth/drive',
      'https://spreadsheets.google.com/feeds/'
    ].freeze

    def initialize(client_id, client_secret, refresh_token)
      @client_id = client_id
      @client_secret = client_secret
      @refresh_token = refresh_token
      @scope = DEFAULT_SCOPE
    end

    def client_id
      @client_id
    end
    def client_secret
      @client_secret
    end
    def refresh_token
      @refresh_token
    end
    def refresh_token=(refresh_token)
      @refresh_token = refresh_token
    end
    def scope
      @scope
    end
    def scope=(scope)
      @scope=scope
    end
    def save
      # This custom config won't save credential file on local.
    end
  end

end
