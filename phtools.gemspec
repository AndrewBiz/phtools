lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'phtools/version'
require 'rbconfig'

Gem::Specification.new do |spec|

  spec.name       = 'phtools'
  spec.version    = PhTools::VERSION
  spec.authors    = ["Andrew Bizyaev"]
  spec.email      = ["andrew.bizyaev@gmail.com"]
  spec.license    = 'MIT'

  spec.summary       = %q(A set of usefull tools to manipulate photo-video files.)
  spec.description   = %q(A bundle of small CLI tools for arranging, renaming, tagging of the photo and video files. Helps to keep your photo-video assets in order.)
  spec.homepage      = "https://github.com/AndrewBiz/phtools.git"

  spec.requirements  = %q{ExifTool by Phil Harvey (http://www.sno.phy.queensu.ca/~phil/exiftool/)}

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.0.0'

  spec.add_development_dependency 'bundler'#, '~> 2.0'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rspec-its'
  spec.add_development_dependency 'cucumber', '~> 2.0'
  spec.add_development_dependency 'aruba', '~> 0.14'
  spec.add_development_dependency 'fuubar'
  spec.add_development_dependency 'guard'
  spec.add_development_dependency 'guard-rspec'
  spec.add_development_dependency 'guard-cucumber'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'bigdecimal', '1.3.5'

  if RbConfig::CONFIG['target_os'] =~ /darwin/i
    spec.add_development_dependency 'terminal-notifier-guard'
  elsif RbConfig::CONFIG['target_os'] =~ /linux/i
    spec.add_development_dependency 'libnotify', '~> 0.8'
  elsif RbConfig::CONFIG['target_os'] =~ /mswin|mingw/i
    spec.add_development_dependency 'win32console'
    spec.add_development_dependency 'rb-notifu', '>= 0'
  end

  spec.add_runtime_dependency 'docopt', '~> 0.5'
  spec.add_runtime_dependency 'mini_exiftool', '~> 2.8'
  spec.add_runtime_dependency 'activesupport', '~> 3.2'
  spec.add_runtime_dependency 'i18n'
  spec.add_runtime_dependency 'bigdecimal', '1.3.5'

  spec.post_install_message = %Q{***\n Thanks for installing phtools! Don't forget to get the ExifTool by Phil Harvey (http://www.sno.phy.queensu.ca/~phil/exiftool/) installed on your system.\n***}
end
