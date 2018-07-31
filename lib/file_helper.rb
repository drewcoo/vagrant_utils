# all of the streaming file-related libs
$LOAD_PATH.unshift(File.expand_path(__dir__))
require 'streaming'

# I should take this as a hint that I should move this
# functionality elsewhere. Both are in download and
# fileutils is in zip.
require 'fileutils'
require 'uri'

#
# A helper class called only by the bin/file tool.
# File actions with progress.
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
    Streaming::Reader::General.new(source) do |reader|
      reader.add_writer(Streaming::Writer::LocalFile.new(target))
      if progress
        bar = Streaming::Writer::Progress.new(title: "#{source} -> #{target}")
        reader.add_writer(bar)
      end
    end
  end

  def self.prep_for_download(source:, dir:, target:)
    # create the dir or we might error later
    FileUtils.mkdir_p dir
    # auto-generate target if none given
    target ||= URI(source).path.split('/').last
    [dir, target].join('/').gsub('//', '/')
  end
  private_class_method :prep_for_download

  def self.download(source, dir:, progress: false, target: nil)
    target = prep_for_download(source: source, dir: dir, target: target)
    # now it's just the same as a copy
    copy(source, target, progress: progress)
  end

  def self.md5(path, progress: false)
    md5 = Streaming::Writer::MD5.new
    Streaming::Reader::General.new(path) do |reader|
      reader.add_writer(md5)
      if progress
        reader.add_writer(Streaming::Writer::Progress.new(title: 'md5 digest'))
      end
    end
    md5.value
  end

  def self.unzip(source, target_dir = nil, progress: false)
    # file foo.bar.baz.zip => dir foo.bar.baz
    target_dir ||= source_file.split('.')[0..-2].join('.')
    FileUtils.mkdir_p(target_dir)

    Streaming::Reader::Zip.new(source) do |reader|
      reader.add_writer(Streaming::Writer::LocalFile.new)
      if progress
        reader.add_writer(Streaming::Writer::Progress.new(title: source))
      end
    end
  end

  def self.http_file_size(source)
    result = nil
    Streaming::Reader::General.new(source) do |reader|
      result = reader.size
    end
    result
  end
end
