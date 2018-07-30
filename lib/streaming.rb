$LOAD_PATH.unshift File.expand_path('streaming', __dir__)

%w[biological_parent general local_file remote_uri zip.rb].each do |file|
  require "reader/#{file}"
end

%w[base local_file md5 progress].each do |file|
  require "writer/#{file}"
end

require 'chunk'
