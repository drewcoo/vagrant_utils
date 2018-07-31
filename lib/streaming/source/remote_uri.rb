require 'httpclient'
require 'source/base_source'
$LOAD_PATH.unshift(File.expand_path('../lib'), __dir__)
require 'utils'

module Streaming
  module Source
    #
    # Reads remote file over http.
    #
    class RemoteURI < BaseSource
      include Utils

      def initialize(*args, &block)
        @size = nil
        super
      end

      def exist?
        Net::HTTP.start(@name.host) do |http|
          return http.request_head(@name.path).is_a? Net::HTTPSuccess
        end
      rescue Errno::ECONNREFUSED
        false
      end

      def open
        c = HTTPClient.new
        conn = c.get_async(@name)
        @handle = conn.pop.content
      end

      # rubocop:disable Metrics/MethodLength
      def size
        retry_with_backoff do
          break @size unless @size.nil?
          Net::HTTP.start(@name.host) do |http|
            response = http.request_head(@name.path)
            unless response.is_a? Net::HTTPSuccess
              raise IOError, response.inspect
            end
            content_length = response['content-length']
            @size = content_length.to_i unless content_length.nil?
          end
        end
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end
