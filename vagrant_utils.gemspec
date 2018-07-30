lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vagrant_utils/version'

Gem::Specification.new do |spec|
  spec.name          = 'vagrant_utils'
  spec.version       = VagrantUtils::VERSION
  spec.authors       = ['Drew Cooper']
  spec.email         = ['drewcoo@gmail.com']

  spec.summary       = 'Vagrant Utilites'
  spec.description   = 'Vagrant files for Modern.IE and Android etc.'
  spec.homepage      = 'https://github.com/drewcoo/vagrant-utils'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set
  # the 'allowed_push_host' to allow pushing to a single host or delete
  # this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org/gems/vagrant-utils'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been
  # added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{^(test|spec|features)/})
    end
  end
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'colorize', '~> 0.8'
  spec.add_runtime_dependency 'httpclient', '~> 2.8'
  spec.add_runtime_dependency 'progressbar', '~> 1.9'
  spec.add_runtime_dependency 'rubyzip', '~> 1.2'
  spec.add_runtime_dependency 'thor', '~> 0.20'

  spec.add_development_dependency 'bundler', '> 1.16'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 0.58'
  spec.add_development_dependency 'ruby-prof', '~> 0.17'
end
