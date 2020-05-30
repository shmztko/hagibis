# frozen_string_literal: true

require 'csv'
require_relative './helpers'
require_relative '../errors'

module RakutenCard
  # 楽天カードの請求情報CSVをパースして、その情報を提供するクラス。
  class BillingCsvParser
    # 請求CSVのヘッダ定義。
    # * プログラム上使用しないが、CSV定義がわかるように記載しておく。
    # * x月支払金額 x+1月繰越残高 の２カラムは、月ごとにヘッダーの値が変わるため x と x+1 でおいてある。
    BILLING_CSV_HEADER = %w[
      利用日 利用店名・商品名 利用者 支払方法 利用金額
      支払手数料 支払総額 x月支払金額 x+1月繰越残高 新規サイン
    ].freeze

    # @param [String] billing_csv_path 楽天カード請求書のファイルパス
    def initialize(billing_csv_path)
      unless File.exist?(billing_csv_path)
        raise Errors::HagibisError, "Parse target file not exists. path : #{billing_csv_path}"
      end

      @billing_csv_path = billing_csv_path
    end

    def total_billing_amount
      CSV.read(@billing_csv_path, headers: true).map do |csv_row|
        csv_row['支払総額'].to_i
      end.sum
    end
  end
end
