$LOAD_PATH.unshift File.expand_path(__dir__)
require 'chunk'
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
  # rubocop:disable Metrics/MethodLength
  def self.copy(source, target, progress: false)
    chunk = Chunk.new(size: File.size(source))
    if progress
      bar = ProgressBar.create(title: "#{source} -> #{target}",
                               total: chunk.total)
    end
    File.open(source, 'rb') do |reader|
      File.open(target, 'wb') do |writer|
        until reader.eof?
          writer.write reader.read(chunk.size)
          bar.progress = chunk.offset if progress
          chunk.next
        end
      end
    end
    bar.finish if progress
  end
  # rubocop:enable Metrics/MethodLength

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def self.download(source, target: nil, dir: nil, progress: false)
    uri = URI(source)
    target = uri.path.split('/').last if target.nil?
    FileUtils.mkdir_p dir
    target = [dir, target].join('/').gsub('//', '/') unless dir.nil?
    if progress
      bar = ProgressBar.create(title: target,
                               total: http_file_size(source))
    end
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

    Net::HTTP.start(uri.host) do |http|
      File.open(target, 'wb') do |file|
        http.get(uri.path) do |chunk|
          file.write chunk
          bar.progress += chunk.length if progress
        end
      end
    end
    bar.finish if progress
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def self.md5(path, progress: false)
    require 'digest'
    result = Digest::MD5.new
    chunk = Chunk.new(size: File.size(path))
    if progress
      bar = ProgressBar.create(title: 'md5 digest', total: chunk.total)
    end
    File.open(path, 'rb') do |reader|
      until reader.eof?
        result.update reader.read(chunk.size)
        bar.progress = chunk.offset if progress
        chunk.next
      end
    end
    bar.finish if progress
    # MSFT passes us MD5 in upcase. Match it.
    result.to_s.upcase
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  def self.unzip(source_file, target_dir = nil)
    # file foo.bar.baz.zip => dir foo.bar.baz
    target_dir ||= source_file.split('.')[0..-2].join('.')
    FileUtils.mkdir_p(target_dir)

    Zip::File.open(source_file) do |zip_file|
      zip_file.each do |file|
        path = File.join(target_dir, file.name)
        zip_file.extract(file, path) unless File.exist?(path)
      end
    end
  end

  def self.http_file_size(source)
    result = 0
    uri = URI(source)
    Net::HTTP.start(uri.host) do |http|
      response = http.request_head(uri.path)
      result = response['content-length'].to_i
      raise IOError, response.inspect unless response.is_a? Net::HTTPSuccess
    end
    result
  end
  private_class_method :http_file_size
end
