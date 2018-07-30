require 'reader/biological_parent'
require 'writer/local_file'

module Streaming
  module Reader
    #
    # Reads a single file from a zipfile. Becuase that's my goal.
    # I shuold really modify all of this later to handle multiple fles.
    # Or at the very least have this message that there are more in there.
    #
    class Zip < BiologicalParent
      def exist?
        ::File.exist?(@name)
      end

      def add_writer(writer)
        if writer.is_a?(Streaming::Writer::LocalFile) && writer.name.nil?
          dir = @name.split('.')[0..-2].join('.')
          file_name = @zip_buffer.first.name
          writer.name = [dir, file_name].join('/').split('\\').join('/')
        end
        super
      end

      def open
        @file_handle = ::File.open(@name, 'rb')
        @zip_buffer = ::Zip::File.open_buffer(@file_handle)
        if (count = @zip_buffer.size != 1)
          raise "#{count} files in zipfile; can only handle one"
        end
        @handle = @zip_buffer.first.get_input_stream
      end

      def size
        @size ||= @zip_buffer.first.size
      end

      def close
        @file_handle.close
      end
    end
  end
end
