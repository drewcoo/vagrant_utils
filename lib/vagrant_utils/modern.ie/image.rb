$LOAD_PATH.unshift File.expand_path(__dir__)
require 'read_only_element'
# the next are required only for md5 lookup
require 'net/http'
require 'uri'

# General MD5 lookup problems
class MD5LookupError < StandardError; end

# can't find the digest in the hash of digests
class NoHashInHash < MD5LookupError
  def initialize(msg = 'Data missing an MD5 for this SKU/VM combination.')
    super
  end
end

# can't find the md5 online
class NoHashOnServer < MD5LookupError
  def initialize(msg = 'URL for MD5 hash invalid.')
    super
  end
end

#
# This is the wrapper for modern.ie vagrant image data - everything MSFT
# tells us about a vm.
#
class Image < ReadOnlyElement
  def types
    result = @data_hash.keys
    result << 'md5' unless result.include? 'md5'
    result.sort
  end

  # override base class to deal with md5
  # and possible md5 lookup exceptions
  def dump
    types.map do |type|
      begin
        "#{type}: #{send(type)}"
      rescue NoHashInHash, NoHashOnServer => e
        "#{type}: EXCEPTION: #{e.exception}"
      end
    end
  end

  # add method to deal with md5 hashes, lazily looked up the first time
  # this is callled
  #
  # BUGBUG: We call exceptional entries every time. This is really only a
  # problem when there's no hash on the server.
  #
  # This mess exists because someone at MSFT decided to store the MD5
  # indirected through  another URl even though this data structure
  # itself was downloaded . . .
  def md5
    if @data_hash['md5'].nil?
      raise NoHashInHash if md5_url.nil?
      response = Net::HTTP.get_response(URI(md5_url))
      raise(NoHashOnServer) unless response.is_a? Net::HTTPSuccess
      @data_hash['md5'] = response.body
    end
    @data_hash['md5']
  end

  #
  # Defined in child class as expected. We can handle files and URIs.
  #
  def self.default_data
    'https://developer.microsoft.com/en-us/microsoft-edge/api/tools/vms/'
  end

  #
  # Defined in child class as expected.
  #
  # Returns an array of Image instances, presumably to a collection class
  # that can do collection-y things like sorting and finding.
  #
  # The whole reason this class exists is because MSFT's data structure
  # makes no sense whatsoever. Someone never heard of hashes, apparently.
  #
  # This is also truly ugly.
  #
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def self.parse(unparsed)
    result = []
    JSON.parse(unparsed).each do |sku|
      sku['software'].each do |vm|
        hash = vm['files'].first.dup
        hash['verbose_sku'] = sku['name']
        hash['verbose_vm'] = vm['name']
        hash['md5_url'] = hash['md5']
        hash.delete('md5')
        split_name = hash['name'].split('.')
        hash['browser'], hash['os'] = split_name[0..1]
        hash['vm'] = split_name[-2] == 'zip' ? split_name[-3] : split_name[-2]
        result << Image.new(hash)
      end
    end
    result
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
end
