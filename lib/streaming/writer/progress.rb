require 'progressbar'
require 'writer/base'

module Streaming
  module Writer
    #
    # Shows progress for file operations.
    #
    class Progress < Base
      attr_accessor :total

      def initialize(title: '', total: nil)
        # pick total up from chunk total?
        @title = title
        @total = total
        super
      end

      def open
        raise 'progress total not set yet' if @total.nil?
        @bar = ProgressBar.create(title: @title, total: @total)
      end

      def write(chunk, _data)
        @bar.progress = chunk.offset
      end

      def close
        @bar.finish
      end
    end
  end
end
