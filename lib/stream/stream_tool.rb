require 'rubygems'
require 'tmpdir'
require 'thor'

#
# The part of this commandline tool that only does file/streaming stuff.
# It should be factored out.
#
class StreamTool < Thor
  DEFAULT_DOWNLOAD_DIR = File.expand_path('download', Dir::tmpdir)

  desc 'copy <source> <target>', 'copy source file to target location'
  def copy(source, target)
    Assert.exist(source)
    Assert.not_exist(target)
    EasyFile.copy(source, target, progress: true)
  end

  desc 'helper: builds full path from dir and file', 'also deals with slashes',
       hide: true
  def full_path(dir, file)
    # array of path elements, joined with slashes
    # The array is the input dir split on slash and backslash plus the file.
    (dir.split(%r{/\\}) << file).join('/')
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
      EasyFile.download(source, dir: dir, progress: true)
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength, Lint/UnneededCopDisableDirective, Metrics/LineLength

  desc 'md5', 'hash of file'
  def md5(source)
    Assert.exist(source)
    actual = EasyFile.digest(source, progress: true)
    puts actual
    actual
  end

  desc 'size <file>', 'tell file size'
  def size(source)
    Assert.exist(source)
    size = EasyFile.size(source)
    puts size
    size
  end

  desc 'unzip <source_file> <target_dir>', 'unzip file to target location'
  def unzip(source, target = nil)
    Assert.exist(source)
    # No target given, unzip foo.zip into directory foo.
    target ||= source.split('.')[0..-2].join('.')
    Assert.not_exist(target)
    EasyFile.unzip(source, target, progress: true)
  end
end
