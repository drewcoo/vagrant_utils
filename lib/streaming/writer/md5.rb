require 'digest'
require 'writer/base'

module Streaming
  module Writer
    #
    # Gets MD5 hash of file read.
    #
    class MD5 < Base
      def initialize
        @value = Digest::MD5.new
        super
      end

      def open
        # nop
      end

      def write(_chunk, data)
        @value.update data
      end

      def close
        # Maybe this helps some calling conventions?
        value
      end

      def value
        @value.to_s.upcase
      end
    end
  end
end
