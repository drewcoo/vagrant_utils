require 'zip'
require 'source/base_source'
require 'writer/local_file'

module Stream
  module Source
    #
    # Reads a single file from a zipfile. Becuase that's my goal.
    # I shuold really modify all of this later to handle multiple fles.
    # Or at the very least have this message that there are more in there.
    #
    class ZipFile < BaseSource
      def exist?
        ::File.exist?(@name)
      end

      def backslashes_to_slashes(string)
        string.split('\\').join('/')
      end

      def directory_name_from_file_name(name)
        # short name minus the file extension
        name.split(%r{/\\}).last.split('.')[0..-2].join('.')
      end

      def add_writer(writer)
        if writer.is_a?(Stream::Writer::LocalFile)
          file = backslashes_to_slashes(@zip_buffer.first.name)
          dir = directory_name_from_file_name(@name)
          FileUtils.mkdir_p(dir)
          writer.name = [dir, file].join('/')
        end
        super
      end

      def open
        @file_handle = ::File.open(@name, 'rb')
        @zip_buffer = Zip::File.open_buffer(@file_handle)
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
        super
      end
    end
  end
end
