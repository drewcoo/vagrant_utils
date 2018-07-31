require 'digest'
require 'writer/base'

module Streaming
  module Writer
    #
    # Gets MD5 hash of file read.
    #
    class Digest < Base
      def initialize(algo = :MD5)
        @value = case algo
                 when :MD5
                   ::Digest::MD5.new
                 when :SHA256
                   ::Digest::SHA256.new
                 else
                   # Should add others. Add automagical determination.
                   raise "Unknown digest type: #{algo}"
                 end
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
