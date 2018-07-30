require 'reader/biological_parent'

module Streaming
  module Reader
    #
    # Reads local files. Might work with netowrk shares. Haven't tried.
    #
    class LocalFile < BiologicalParent
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
