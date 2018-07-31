require 'spec_helper'
require File.expand_path('file_tool_wrapper', __dir__)

# rubocop:disable Style/MutableConstant
FILE_VM_DATA_JSON = File.expand_path('vm_data.json', __dir__)
FILE_VM_DATA_ZIP = File.expand_path('vm_data.zip', __dir__)
FILE_TMP_DUMMY_TXT = File.expand_path('..\tmp\dummy.txt', __dir__)

URL_DOWNLOAD_DUMMY = 'https://www.iana.org/_img/2013.1/iana-logo-header.svg'
URL_VM_FOR_MD5_CHECK = 'https://az792536.vo.msecnd.net/vms/md5/' \
                       'VMBuild_20180102/IE11.Win81.HyperV.zip.md5.txt'
MD5_FOR_MD5_CHECK = 'A3ECD1D4E53C5D11F162A18331D429C6'
# rubocop:enable Style/MutableConstant

def entry_count(output)
  output.lines.count { |line| line.match(/^browser\:/) }
end

def entry_values(output, name)
  result = []
  output.lines.each do |line|
    found = line.match(/^#{name}\: (.+)/)
    result << found[1] unless found.nil?
  end
  result
end

def entry_value(output, name)
  result = entry_values(output, name)
  raise "#{result.length} entries!" if result.length != 1
  result.first
end

# rubocop:disable Metrics/BlockLength
RSpec.describe 'FileTool', :slow do
  let(:file) do
    ENV['VM_DATA'] = FILE_VM_DATA_JSON
    FileToolWrapper.new
  end

  let(:dummy_source) do
    source = FILE_VM_DATA_JSON
    target = FILE_TMP_DUMMY_TXT
    FileUtils.cp(source, target)
    @created_dummy_source = target
  end

  let(:download_dummy) do
    url = URL_DOWNLOAD_DUMMY
    basename = url.split('/').last
    @created_download_dummy = File.expand_path("../tmp/download/#{basename}",
                                               __dir__)
    url
  end

  let(:dummy_target) do
    @created_dummy_target = File.expand_path('..\tmp\download\dummy_copy.txt',
                                             __dir__)
  end

  let(:zipped_file) do
    @zipped_file = File.expand_path('../tmp/vm_data.zip', __dir__)
    @unzipped_file = File.expand_path('../tmp/vm_data/vm_data.json', __dir__)
    @unzipped_dir = File.expand_path('../tmp/vm_data', __dir__)
    FileUtils.mkdir_p(File.expand_path('../tmp', __dir__))
    FileUtils.cp(FILE_VM_DATA_ZIP, @zipped_file)
    @zipped_file
  end

  after do
    [@created_dummy_source, @created_download_dummy,
     @created_dummy_target, @zipped_file].each do |f|
      File.delete(f) if !f.nil? && File.exist?(f)
    end
    FileUtils.rm_rf(@unzipped_dir) unless @unzipped_dir.nil?
  end

  context '#copy' do
    it 'can copy a file' do
      file.copy "#{dummy_source} #{dummy_target}"
      expect(file.stderr).to eq('')
      expect(file.status).to eq(0)
    end

    it 'fails when no source file' do
      file.copy
      expect(file.stderr).to match('no arguments')
      # returns 0 because it's broken (again)
      # bug first reported by Mike Saffitz of all people:
      # https://github.com/erikhuda/thor/issues/244
      # expect(file.status).to eq(1)
    end

    it 'fails when no target file' do
      file.copy dummy_source
      expect(file.stderr).to match('was called with arguments')
      # expect(file.status).to eq(1)
    end

    it 'fails when more than two args' do
      file.copy 'a b c'
      expect(file.stderr).to match('was called with arguments')
      # expect(file.status).to eq(1)
    end
  end

  context '#download' do
    it 'can download' do
      file.download download_dummy
      expect(file.stderr).to eq('')
      expect(file.status).to eq(0)
    end

    it 'can download to a path' do
      dir = dummy_target.split(%r{/|\\})[0..-2].join('/')
      file.download "#{download_dummy} -d #{dir}"
      expect(file.stderr).to eq('')
      expect(file.status).to eq(0)
    end
  end

  context '#find' do
    it 'with no args returns all items' do
      file.find
      expect(entry_count(file.stdout)).to eq(30)
    end

    it 'can find by browser' do
      # TODO: Can't randomly select browser and expect count unless I
      # have a hash of all browsers and counts. There are different numbers
      # of browsers of each version.
      # browsers = %w[IE8 IE9 IE10 IE11 MSEdge]
      # this_browser = browsers[rand(browsers.size)]
      file.find '--browser IE10'
      expect(entry_count(file.stdout)).to eq(5)
    end

    # currently can't but should be able to
    xit 'can find by md5' do
    end

    it 'can find by md5_url' do
      file.find "--md5_url #{URL_VM_FOR_MD5_CHECK}"
      expect(entry_value(file.stdout, 'md5')).to eq(MD5_FOR_MD5_CHECK)
    end

    xit 'can find by name' do
    end

    xit 'can find by os' do
    end

    xit 'can find by url' do
    end

    xit 'can find by verbose_sku' do
    end

    xit 'can find by verbose_vm' do
    end

    xit 'can find by vm' do
    end
  end

  context '#md5' do
    it 'can find an md5' do
      file.download download_dummy
      file.md5 @created_download_dummy
      expect(file.stderr).to eq('')
      expect(file.stdout).to match('426B3AC01D3584C820F3B7F5985D6623')
      expect(file.status).to eq(0)
    end

    xit 'can verify md5 against data' do
    end
  end

  context '#unzip' do
    it 'can unzip a file' do
      file.unzip zipped_file
      expect(file.stderr).to eq('')
      expect(FileUtils.identical?(@unzipped_file, FILE_VM_DATA_JSON)).to be true
    end
  end

  context '#values' do
    it 'can query all browsers' do
      file.values 'browser'
      expect(file.stdout.lines.count).to eq(5)
    end

    xit 'can query all of the other things and be correct' do
    end
  end
end
# rubocop:enable Metrics/BlockLength
