# lib dir
$LOAD_PATH.unshift File.expand_path('..\..', __dir__)
require 'streaming'

$LOAD_PATH.unshift File.expand_path(__dir__)
require 'fileutils'
require 'net/http'
require 'progressbar'
require 'uri'
require 'zip'

#
# Maybe rubyzip to unzip these files?
# https://github.com/rubyzip/rubyzip
#
# Verify Digest::MD5.hexdigest(file) once unzipped, I assume?
# require 'digest' for that
#

#
# File methods w/ progress where possible.
# Not possible w/ zipfiles because it looked like way too much work to make
# rubyzip do buffered IO and jam progress bar progress into it.
#
class FileHelper
  #
  # can SocketError if connection dropped
  #
  # If new download, do this.
  #
  # But if continue stopped download,
  # start progress the same
  # get size of local file
  # set chunk to that
  # start download at that offset
  # append to local file
  #
  def self.copy(source, target, progress: false)
    reader = Streaming::Reader::General.new(source)
    reader.add_writer(Streaming::Writer::LocalFile.new(target))
    if progress
      bar = Streaming::Writer::Progress.new(title: "#{source} -> #{target}")
      reader.add_writer(bar)
    end
    reader.write
  end

  def self.download(source, dir:, progress: false, target: nil)
    # auto-generate target if none given
    target ||= URI(source).path.split('/').last
    target = [dir, target].join('/').gsub('//', '/')
    # and create the dir or we might error later
    FileUtils.mkdir_p dir
    # now it's just the same as a copy
    copy(source, target, progress: progress)
  end

  def self.md5(path, progress: false)
    reader = Streaming::Reader::General.new(path)
    reader.add_writer(md5 = Streaming::Writer::MD5.new)
    if progress
      reader.add_writer(Streaming::Writer::Progress.new(title: 'md5 digest'))
    end
    reader.write
    md5.value
  end

  def self.unzip(source, target_dir = nil, progress: false)
    # file foo.bar.baz.zip => dir foo.bar.baz
    target_dir ||= source_file.split('.')[0..-2].join('.')
    FileUtils.mkdir_p(target_dir)

    reader = Streaming::Reader::Zip.new(source)
    reader.add_writer(Streaming::Writer::LocalFile.new)
    if progress
      reader.add_writer(Streaming::Writer::Progress.new(title: source))
    end
    reader.write
  end

  def self.http_file_size(source)
    reader = Streaming::Reader::General.new(source)
    result = reader.size
    reader.close
    result
  end
  private_class_method :http_file_size
end
