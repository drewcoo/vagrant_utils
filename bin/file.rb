#!/usr/bin/env ruby
$LOAD_PATH.unshift File.expand_path '../lib/vagrant_utils/modern.ie', __dir__
require 'assert'
require 'collection'
require 'file_helper'
require 'image'

require 'rubygems'
require 'thor'

#
# A command line tool to deal with vagrant files
#
class FileTool < Thor
  DEFAULT_DOWNLOAD_DIR = File.expand_path('../tmp/download', __dir__)

  desc 'copy <source> <target>', 'copy source file to target location'
  def copy(source, target)
    Assert.exist(source)
    Assert.not_exist(target)
    FileHelper.copy(source, target, progress: true)
  end

  desc 'data_puts_list', 'outputs list of vm data elements', hide: true
  def data_puts_list(list)
    list.each_index do |index|
      puts unless index.zero?
      puts list[index].dump
    end
  end

  desc 'download <source> [-d <dir>] [-n]',
       'download file from url to directory'
  method_option :new, aliases: '-n', desc: 'start download in a new process',
                      type: :boolean
  method_option :dir, aliases: '-d', desc: 'download directory'
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Lint/UnneededCopDisableDirective, Metrics/LineLength
  def download(source)
    Assert.exist(source)
    dir = options.dir || DEFAULT_DOWNLOAD_DIR
    target = source.split('/').last
    Assert.not_exist(full_path(dir, target))
    if options.new
      # "cmd /k" leaves the cmd window open but "&& exit" will close it
      # if the ruby command exits with nonzero. So we stay open on failures
      # to diagnose things like exceptions being raised.
      system "start \"#{target}\" cmd /k " \
             "\"ruby #{__FILE__} download #{source} -d #{dir} && exit\""
    else
      FileHelper.download(source, dir: dir, progress: true)
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength, Lint/UnneededCopDisableDirective, Metrics/LineLength

  desc 'find', 'take a bunch of args or none at all'
  method_option :browser
  # method_option :md5 # currently not an option because of having to fetch
  # all md5s from server and some missing. Should fix this!
  method_option :md5_url
  method_option :name
  method_option :os
  method_option :url
  method_option :verbose_sku
  method_option :verbose_vm
  method_option :vm
  def find
    result = vm_data.find(options)
    data_puts_list result
  end

  desc 'helper: builds full path from dir and file', 'also deals with slashes',
       hide: true
  def full_path(dir, file)
    # array of path elements, joined with slashes
    # The array is the input dir split on slash and backslash plus the file.
    (dir.split(%r{/\\}) << file).join('/')
  end

  desc 'md5', 'hash of file'
  method_option :verify, aliases: '-v', desc: 'check against md5s in vm data',
                         type: :boolean
  def md5(source)
    Assert.exist(source)
    actual = FileHelper.md5(source, progress: true)
    if options.verify
      expected = vm_data.find(name: File.basename(source)).first.md5
      Assert.equal(actual, expected)
    end
    puts actual
  end

  desc 'unzip <source_file> <target_dir>', 'unzip file to target location'
  def unzip(source, target = nil)
    Assert.exist(source)
    # No target given, unzip foo.zip into directory foo.
    target ||= source.split('.')[0..-2].join('.')
    Assert.not_exist(target)
    FileHelper.unzip(source, target, progress: true)
  end

  desc 'values', 'all types for field name'
  # values for field - one of:
  # browser, md5, md5_url, name, os, url, verbose_sku,
  # verbose_vm, vm
  def values(field)
    result = vm_data.values(field)
    puts result
  end

  desc 'MSFT VM data', 'web-fetches as needed', hide: true
  def vm_data
    # This is intended for testing only so I'm not promoting it to a
    # regular option.
    my_options = { type: Image }
    my_options[:data] = ENV['VM_DATA'] if ENV['VM_DATA']
    # Do not do this:
    # Assert.exist(Image.default_data)
    # Because MSFT's json returns Net::HTTPMovedPermanently on HEAD.
    @vm_data ||= Collection.new(my_options)
  end
end

FileTool.start
