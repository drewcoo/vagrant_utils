require 'writer/base'

module Stream
  module Writer
    #
    # Writes to a local file.
    #
    class LocalFile < Base
      attr_accessor :name

      def initialize(name = nil)
        @name = name
        super
      end

      def open
        @handle = ::File.open(@name, 'wb')
      end

      def write(_chunk, data)
        @handle.write data
      end

      def close
        @handle.close
      end
    end
  end
end
