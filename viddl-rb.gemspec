Gem::Specification.new do |s|
  s.name        = "viddl-rb"
  s.version     = "0.81"
  s.author      = "Marc Seeger"
  s.email       = "mail@marc-seeger.de"
  s.homepage    = "https://github.com/rb2k/viddl-rb"
  s.summary     = "An extendable commandline video downloader for flash video sites."
  s.description = "An extendable commandline video downloader for flash video sites. Includes plugins for vimeo, youtube, dailymotion and more"
  s.has_rdoc    = false
  s.files       = Dir["{bin,lib,helper,plugins}/**/*"] + Dir["[A-Z]*"] + ["README.md"]
  s.require_paths = ['lib']
  s.executables = ['viddl-rb']
  
  s.rubyforge_project = s.name
  s.required_rubygems_version = ">= 1.3.4"

  s.add_dependency "jruby-openssl" if RUBY_PLATFORM == "java"
  # We still want to support 1.8.7
  s.add_dependency('nokogiri', '~> 1.5.0')
  s.add_dependency('mechanize')
  s.add_dependency('progressbar')
  s.add_development_dependency('rake')
  s.add_development_dependency('rest-client')
  s.add_development_dependency('minitest')
  
end
