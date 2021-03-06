# frozen_string_literal: true

module LineBot
  module Helpers
    # LINE へ送信する本文を組み立てるクラス
    class BodyBuilder
      attr_reader :body

      STICKER_POOL = %w[
        52002734
        52002735
        52002763
        52002771
        52002748
        52002768
        52002753
      ].freeze

      def initialize
        @body = []
      end

      def random_sticker
        @body << {
          type: 'sticker',
          packageId: '11537',
          stickerId: STICKER_POOL[rand(7)]
        }
        self
      end

      def text(message)
        @body << { type: 'text', text: message }
        self
      end
    end
  end
end
