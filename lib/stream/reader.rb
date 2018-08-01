require 'source/local_file'
require 'source/remote_uri'
require 'source/zip_file'

module Stream
  #
  # Should make this handle zipfiles, too.
  # From local files or http.
  #
  # This seems to be the parent class for the Stream sources but actually
  # only pretends and introduces them. See BiologicalParent.
  #
  # Handles local zipfiles. Not zipfles over http.
  #
  # rubocop:disable Metrics/MethodLength
  class Reader
    def initialize(name, &block)
      @instance = case uri = URI(name.tr('\\', '/'))
                  when URI::HTTP
                    Stream::Source::RemoteURI.new(uri, &block)
                  when URI::Generic
                    if name.match?(/\.zip$/)
                      Stream::Source::ZipFile.new(name, &block)
                    else
                      Stream::Source::LocalFile.new(name, &block)
                    end
                  else
                    raise "file \"#{name}\" is unknown type #{uri.class}"
                  end
    end
    # rubocop:enable Metrics/MethodLength

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
