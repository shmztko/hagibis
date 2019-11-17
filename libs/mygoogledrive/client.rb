require "google_drive"
require_relative "./config"
module MyGoogleDrive

  class Client

    attr_reader :session

    def initialize(client_id, client_secret, refresh_token)
      @session = GoogleDrive::Session.from_config(Config.new(client_id, client_secret, refresh_token))
    end

    # 指定されたリソースID以下に、サブディレクトリを作成し、そのサブディレクトリの下にファイルをアップロードします。
    # @param [String] upload_root サブディレクトリを作成する先のリソース
    # @param [String] src_path アップロード元ファイルのパス
    # @param [String] subdir_name サブディレクトリの名前
    def upload_file_with_subdir(upload_root, src_path, subdir_name)
      subdir = upload_root.subcollection_by_title(subdir_name.to_s)
      if subdir.nil?
        subdir = upload_root.create_subcollection(subdir_name.to_s)
      end
      upload_file(subdir, src_path)
    end

    # 指定されたリソース以下にファイルをアップロードします。
    # * デフォルトでは実施されない同名ファイルの存在チェックを行い、もし同名ファイルがある場合はアップロードをスキップします。
    # @param [GoogleDrive::Collection] upload_dest アップロード先のリソース
    # @param [String] src_path アップロード元ファイルのパス
    def upload_file(upload_dest, src_path)
      Logger.info("Uploading file:#{src_path} to resrouce_id:#{upload_dest}")

      # Google Drive では、同じフォルダ配下に同じ名前のファイルが作成できてしまうので、
      # ファイル名 で 検索してすでにアップロード済みであればスキップする。
      src_filename = File.basename(src_path)
      found = upload_dest.file_by_title(src_filename)
      if found.nil?
        # デフォルトは、convert: true だが、変換されると拡張子が消されてしまうため、
        # 前段のファイル名チェックで検索できなくなるので、convert: false にする。
        upload_dest.upload_from_file(src_path, src_filename, convert: false)
      else
        Logger.info("[SKIPPED] File '#{src_filename}' was already on Google Drive.")
        found
      end
    end
  end
end
