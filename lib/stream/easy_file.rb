# all of the Stream file-related libs
$LOAD_PATH.unshift(File.expand_path(__dir__))
require 'stream'

# I should take this as a hint that I should move this
# functionality elsewhere. Both are in download and
# fileutils is in zip.
require 'fileutils'
require 'uri'

#
# A helper class called only by the bin/file tool.
# File actions with progress.
#
class EasyFile
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
    Stream::Reader.new(source) do |reader|
      reader.add_writer(Stream::Writer::LocalFile.new(target))
      if progress_text
        reader.add_writer(Stream::Writer::Progress.new(title: progress_text))
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

  def self.digest(source, algo: :MD5, progress: false)
    digest = Stream::Writer::Digest.new(algo)
    # Need to change ZipFile to a filter instead of a source because it unzips
    # Stream::Reader.new(source) do |reader|
    Stream::Source::LocalFile.new(source) do |reader|
      reader.add_writer(digest)
      if progress
        reader.add_writer(Stream::Writer::Progress.new(title: 'finding digest'))
      end
    end
    digest.value
  end

  def self.unzip(source, target = nil, progress: false)
    progress_text = progress && "unzip #{source}"
    common_worker(source, target, progress_text: progress_text)
  end

  def self.size(source)
    result = nil
    Stream::Reader.new(source) do |reader|
      result = reader.size
    end
    result
  end
end
