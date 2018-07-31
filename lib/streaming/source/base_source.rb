module Streaming
  module Source
    #
    # The real parent of the streaming sources even though they're all accessed
    # through another class that's just pretending.
    #
    class BaseSource
      #
      # The optinal block passed in here allows this calling convention:
      #
      # Streaming::Source::General.new(source) do |source|
      #    source.add_writer(Streaming::Writer::LocalFile.new(target))
      # end
      #
      # Otherwise it should be used like this:
      #
      # source = Streaming::Source::General.new(source)
      # source.add_writer(Streaming::Writer::LocalFile.new(target))
      # source.write
      # source.close
      #
      def initialize(name, &block)
        @writers = []
        @name = name
        raise "File \"#{uri}\" does not exist!" unless exist?
        open
        return if block.nil?
        yield self
        write
        close
      end

      def read(size)
        @handle.read(size)
      end

      def add_writer(writer)
        writer.total = size if writer.is_a? Streaming::Writer::Progress
        @writers << writer
      end

      def write
        # For some things (like checking file size of URIs) we want to open
        # the file and call some method on the source but not actually
        # slurp the file.
        return if @writers.empty?
        chunk = Chunk.new(size: size)
        @writers.each(&:open)
        until chunk.finished?
          data = read(chunk.size)
          @writers.each { |writer| writer.write(chunk, data) }
          chunk.next
        end
      end

      def close
        @writers.each(&:close)
        @handle.close
      end
    end
  end
end
