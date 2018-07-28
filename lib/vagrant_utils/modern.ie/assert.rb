$LOAD_PATH.unshift File.expand_path __dir__
require 'colorize'
require 'file_helper'

#
# A bunch of assertions that, if they fail, will exit with
# red error messages.
#
class Assert
  def self.exist(name)
    return if exist?(name)
    bail! "file \"#{name}\" does not exist"
  end

  def self.not_exist(name)
    return unless exist?(name)
    bail! "file \"#{name}\" already exist"
  end

  def self.equal(first, second)
    return if first == second
    bail! "expected: \"#{first}\"; found: \"#{second}\""
  end

  #
  # The following are all private methods called by the above publics.
  #

  def self.bail!(string)
    abort "ERROR: #{string}".colorize(:red)
  end
  private_class_method :bail!

  def self.exist?(name)
    case uri = URI(name.tr('\\', '/'))
    when URI::HTTP
      uri_exist?(uri)
    when URI::Generic
      File.exist?(name)
    else
      bail! "file \"#{name}\" is unknown type #{uri.class}"
    end
  end
  private_class_method :exist?

  def self.uri_exist?(uri)
    Net::HTTP.start(uri.host) do |http|
      return http.request_head(uri.path).is_a? Net::HTTPSuccess
    end
  rescue Errno::ECONNREFUSED
    false
  end
  private_class_method :uri_exist?
end
