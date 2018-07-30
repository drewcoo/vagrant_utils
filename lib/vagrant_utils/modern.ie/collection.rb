# clases having to do with the collection of data
# we slurp from the json file MSFT hands us
$LOAD_PATH.unshift(File.expand_path('collection', __dir__))
require 'collection'
require 'image'
require 'read_only_element'
