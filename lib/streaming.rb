$LOAD_PATH.unshift(File.expand_path('streaming', __dir__))

%w[base_source local_file remote_uri zip_file].each do |file|
  require "source/#{file}"
end

%w[base local_file md5 progress].each do |file|
  require "writer/#{file}"
end

require 'assert'
require 'chunk'
require 'reader'
