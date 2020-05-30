# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RakutenCard::BillingCsvParser do
  describe '#initialize' do
    context '存在しないファイルパスを渡した場合' do
      it '例外を投げること' do
        expect do
          described_class.new('file_path_not_exists')
        end.to raise_error Errors::HagibisError
      end
    end
  end

  describe '#total_billing_amount' do
    let(:csv_file) do
      Tempfile.open('test.csv') do |temp_file|
        temp_file.puts(
          '"利用日","利用店名・商品名","利用者","支払方法","利用金額","支払手数料","支払総額","５月支払金額","６月繰越残高","新規サイン"',
          '"2020/04/28","利用店舗１","本人","1回払い","1000","0","1000","1000","0","*"',
          '"2020/04/01","利用店舗２","家族","1回払い","2000","0","2000","2000","0","*"'
        )
        temp_file
      end
    end

    after do
      File.delete(csv_file) if File.exist?(csv_file.path)
    end

    subject { described_class.new(csv_file.path).total_billing_amount }

    it '総請求額を返すこと' do
      is_expected.to eq 3000
    end
  end
end
