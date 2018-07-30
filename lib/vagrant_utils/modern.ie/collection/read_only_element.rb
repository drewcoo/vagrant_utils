require 'net/http'
require 'uri'

#
# Elements of Collections
# These are read-only. Well, ok, more like "write once."
#
class ReadOnlyElement
  def initialize(hash)
    @data_hash = hash
  end

  def types
    result = @data_hash.keys
    result.sort
  end

  def dump
    types.map do |type|
      begin
        "#{type}: #{send(type)}"
      end
    end
  end

  def method_missing(method, *args, &block)
    if args.empty? && @data_hash.include?(method.to_s)
      @data_hash[method.to_s]
    else
      super
    end
  end

  def respond_to_missing?(*args)
    args.length = 1 && @data_hash.include?(args[0])
  end

  def self.default_data
    raise 'Child classes must implement this method.'
  end

  def self.parse(_unparsed)
    raise 'Child classes must implement this method.'
  end
end
