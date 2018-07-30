require 'httpclient'
require 'reader/biological_parent'

module Streaming
  module Reader
    #
    # Reads remote file over http.
    #
    class RemoteURI < BiologicalParent
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

      def size
        return @size unless @size.nil?
        Net::HTTP.start(@name.host) do |http|
          response = http.request_head(@name.path)
          @size = response['content-length'].to_i
          raise IOError, response.inspect unless response.is_a? Net::HTTPSuccess
        end
        @size
      end
    end
  end
end
