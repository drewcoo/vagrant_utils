$LOAD_PATH.unshift(File.expand_path('stream', __dir__))

%w[base_source local_file remote_uri zip_file].each do |file|
  require "source/#{file}"
end

%w[base digest local_file progress].each do |file|
  require "writer/#{file}"
end

require 'assert'
require 'easy_file'
require 'chunk'
require 'reader'
require 'stream_tool'
