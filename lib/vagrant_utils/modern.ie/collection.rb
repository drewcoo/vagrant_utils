require 'json'
require 'net/http'
require 'uri'

#
# A collection of elements.
# In this case, Images, a subclass of ReadOnlyElement,
# representing all of the VMs modern.ie tells us are available.
#
class Collection
  attr_reader :type

  #
  # type: the required class of things in the Collection
  # data: optional file or URI path to load the data from
  #       we default to @type.default_data_location
  #
  def initialize(type:, data: nil)
    @type = type
    data = @type.default_data if data.nil?
    @entries = @type.parse(read_data(data))
  end

  def values(field)
    result = []
    @entries.each do |item|
      value = item.send(field.to_s)
      result << value unless result.include? value
    end
    result
  end

  def random_entry
    @entries[rand(@entries.length)]
  end

  def find(options = {})
    result = @entries.dup
    options.each_pair do |k, v|
      break if result.empty?
      result.delete_if { |e| e.send(k) != v }
    end
    result
  end

  private

  def read_data(data)
    case uri = URI(data.tr('\\', '/'))
    when URI::HTTP
      Net::HTTP.get(uri)
    when URI::Generic
      File.read(data)
    else
      raise "ERROR: Unknown input type #{uri.class}"
    end
  end
end
