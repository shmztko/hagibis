module MyGoogleDrive
  # Session#from_config へ渡す config は、指定されたメソッドを実装しているカスタムクラスでも可。
  # Ref : https://www.rubydoc.info/gems/google_drive/GoogleDrive%2FSession.from_config
  class Config

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