Gem::Specification.new do |s|
  s.name        = "viddl-rb"
  s.version     = "1.0.1"
  s.author      = "Marc Seeger"
  s.email       = "mail@marc-seeger.de"
  s.license     = 'MIT'
  s.homepage    = "https://github.com/rb2k/viddl-rb"
  s.summary     = "An extendable commandline video downloader for flash video sites."
  s.description = "An extendable commandline video downloader for flash video sites. Includes plugins for vimeo, youtube, dailymotion and more"
  s.has_rdoc    = false
  s.files       = Dir["{bin,lib,helper,plugins}/**/*"] + Dir["[A-Z]*"] + ["README.md"]
  s.require_paths = ['lib']
  s.executables = ['viddl-rb']
  s.rubyforge_project = s.name
  s.required_rubygems_version = ">= 1.3.4"
  s.required_ruby_version = ">= 1.9.0"

  s.add_dependency "jruby-openssl" if RUBY_PLATFORM == "java"
  s.add_dependency('mime-types', '~> 2.1.0')
  s.add_dependency('nokogiri', '~> 1.6.0')
  s.add_dependency('progressbar', '~> 0.21')
  s.add_dependency('multi_json', '~> 1.10.0')
  s.add_development_dependency('rake', '~> 10.1.0')
  s.add_development_dependency('rest-client', '~> 1.6.7')
  s.add_development_dependency('minitest')
end
