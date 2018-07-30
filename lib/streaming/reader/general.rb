require 'reader/local_file'
require 'reader/remote_uri'

module Streaming
  module Reader
    #
    # Should make this handle zipfiles, too.
    # From local files or http.
    #
    # This seems to be the parent class for the streaming readers but actually
    # only pretends and introduces them. See BiologicalParent.
    #
    class General
      def initialize(name, &block)
        case uri = URI(name.tr('\\', '/'))
        when URI::HTTP
          @instance = Streaming::Reader::RemoteURI.new(uri, &block)
        when URI::Generic
          @instance = Streaming::Reader::LocalFile.new(name, &block)
        else
          raise "file \"#{name}\" is unknown type #{uri.class}"
        end
      end

      def method_missing(method, *args)
        name = method.to_s
        super unless respond_to_missing? name
        @instance.send(name, *args)
      end

      def respond_to_missing?(method, _include_all)
        %w[add_writer close exist? open read size write].include? method
      end
    end
  end
end
