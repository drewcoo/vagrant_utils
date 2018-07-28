require 'spec_helper'
require File.expand_path('file_tool_wrapper', __dir__)

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
    ENV['VM_DATA'] = File.expand_path('vm_data.json', __dir__)
    FileToolWrapper.new
  end

  let(:dummy_source) do
    source = File.expand_path('vm_data.json', __dir__)
    target = File.expand_path('..\tmp\dummy.txt', __dir__)
    FileUtils.cp(source, target)
    @created_dummy_source = target
  end

  let(:download_dummy) do
    url = 'https://www.iana.org/_img/2013.1/iana-logo-header.svg'
    basename = url.split('/').last
    @created_download_dummy = File.expand_path("../tmp/download/#{basename}",
                                               __dir__)
    url
  end

  let(:dummy_target) do
    @created_dummy_target = File.expand_path('..\tmp\download\dummy_copy.txt',
                                             __dir__)
  end

  after do
    [@created_dummy_source, @created_download_dummy,
     @created_dummy_target].each do |f|
      File.delete(f) if !f.nil? && File.exist?(f)
    end
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

    xit 'can download and verify md5' do
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
      # rubocop:disable Metrics/LineLength
      file.find '--md5_url https://az792536.vo.msecnd.net/vms/md5/VMBuild_20180102/IE11.Win81.HyperV.zip.md5.txt'
      expect(entry_value(file.stdout, 'md5')).to eq('A3ECD1D4E53C5D11F162A18331D429C6')
      # rubocop:enable Metrics/LineLength
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
    # need fake file .json w/ md5 matching a file for this
  end

  context '#unzip' do
    # need a zipped file and something known about its unzipped self
    # probably a fake file .json w/ an md5 for the unzipped file
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
