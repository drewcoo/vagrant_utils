#!/usr/bin/env ruby

#
# TODO: Remove this eventually.
#
# This is just a place to play with VM collections and downloading
# before we get the non-library code into a command line tool.
#
$LOAD_PATH.unshift File.expand_path('../lib/vagrant_utils/modern.ie', __dir__)
require 'collection'
require 'image'
require 'utils'
# rubocop:disable Style/MixinUsage
include Utils
# rubocop:enable Style/MixinUsage

$LOAD_PATH.unshift File.expand_path(__dir__)
require 'file'

data = Collection.new(type: Image)
# data_path = File.expand_path('../spec/vm_data.json', __dir__)
# data = data: Collection.new(type: Image, data: data_path)

puts_table 'Image types', data.random_entry.types
puts_table 'sample image:', data.random_entry.dump

verbose_skus = data.data('verbose_sku')
puts_table 'SKUs', verbose_skus

verbose_vms = data.data('verbose_vm')
puts_table 'VMs by verbose name', verbose_vms

puts_table 'VMs by .vm (parsed from file name)', data.data(:vm)

puts
found = data.find(verbose_sku: verbose_skus[rand(verbose_skus.length)],
                  verbose_vm: verbose_vms[rand(verbose_vms.length)])
found.each { |f| puts f.dump }

10.times { puts }
data.find(vm: 'Vagrant').each do |box|
  puts
  puts box.dump
  # FileTool.start(['download', box.url, '-n'])
end

#
# The password on all boxes is: "Passw0rd!"
#

# used for some download testing:
# source = 'https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png'
