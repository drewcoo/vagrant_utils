module Streaming
  module Reader
    #
    # The real parent of the streaming readers even though they're all accessed
    # through another class that's just pretending.
    #
    class BiologicalParent
      def initialize(name)
        @writers = []
        @name = name
        raise "File \"#{uri}\" does not exist!" unless exist?
        open
      end

      def read(size)
        @handle.read(size)
      end

      def add_writer(writer)
        writer.total = size if writer.is_a? Streaming::Writer::Progress
        @writers << writer
      end

      def write
        chunk = Chunk.new(size: size)
        @writers.each(&:open)
        until chunk.finished?
          data = read(chunk.size)
          @writers.each { |writer| writer.write(chunk, data) }
          chunk.next
        end
        @writers.each(&:close)
        close
      end

      def close
        @handle.close
      end
    end
  end
end
