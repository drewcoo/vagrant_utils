require 'source/base_source'

module Streaming
  module Source
    #
    # Reads local files. Might work with netowrk shares. Haven't tried.
    #
    class LocalFile < BaseSource
      def exist?
        ::File.exist?(@name)
      end

      def open
        @handle = ::File.open(@name, 'rb')
      end

      def size
        @size ||= ::File.size(@name)
      end
    end
  end
end
