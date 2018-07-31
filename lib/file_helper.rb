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
  def self.common_worker(source, target, progress_text: nil)
    Streaming::Reader.new(source) do |reader|
      reader.add_writer(Streaming::Writer::LocalFile.new(target))
      if progress_text
        bar = Streaming::Writer::Progress.new(title: progress_text)
        reader.add_writer(bar)
      end
    end
  end
  private_class_method :common_worker

  def self.copy(source, target, progress: false)
    progress_text = progress && "#{source} -> #{target}"
    common_worker(source, target, progress_text: progress_text)
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
    progress_text = progress && "download #{source}"
    common_worker(source, target, progress_text: progress_text)
  end

  def self.md5(path, progress: false)
    md5 = Streaming::Writer::MD5.new
    Streaming::Reader.new(path) do |reader|
      reader.add_writer(md5)
      if progress
        reader.add_writer(Streaming::Writer::Progress.new(title: 'md5 digest'))
      end
    end
    md5.value
  end

  def self.unzip(source, target = nil, progress: false)
    progress_text = progress && "unzip #{source}"
    common_worker(source, target, progress_text: progress_text)
  end

  def self.http_file_size(source)
    result = nil
    Streaming::Reader.new(source) do |reader|
      result = reader.size
    end
    result
  end
end
