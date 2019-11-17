require "google_drive"
require_relative "./config"
module MyGoogleDrive
  def self.new_client(client_id, client_secret, refresh_token)
    GoogleDrive::Session.from_config(Config.new(client_id, client_secret, refresh_token))
  end
end
