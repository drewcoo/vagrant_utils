FILE_TOOL_PATH = File.expand_path('../bin/file.rb', __dir__)

require 'open3'

#
# A class to wrap scc.rb for test purposes.
# It does ugly things.
#
class FileToolWrapper
  attr_accessor :stdout, :stderr, :status

  def call(string)
    @stdout = @stderr = ''
    command = "ruby #{FILE_TOOL_PATH} #{string}"
    @stdout, @stderr, @status = Open3.capture3(command)
  end

  def method_missing(method, *args)
    name = method.to_s
    super unless respond_to_missing? name
    call args.empty? ? name : "#{name} #{args.join(' ')}"
  end

  def respond_to_missing?(method)
    # hidden: full_path data_puts_list
    %w[copy download find md5 unzip values].include? method
  end
end
