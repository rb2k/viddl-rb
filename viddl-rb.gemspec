Gem::Specification.new do |s|
  s.name        = "viddl-rb"
  s.version     = "0.4.8"
  s.author      = "Marc Seeger"
  s.email       = "mail@marc-seeger.de"
  s.homepage    = "https://github.com/rb2k/viddl-rb"
  s.summary     = "An extendable commandline video downloader for flash video sites."
  s.description = "An extendable commandline video downloader for flash video sites. Includes plugins for vimeo, youtube and megavideo"

  s.files        = Dir["{bin,helper,plugins}/**/*"] + Dir["[A-Z]*"] + ["README.txt", "CHANGELOG.txt"]
  s.executables = ['viddl-rb']
  
  s.rubyforge_project = s.name
  s.required_rubygems_version = ">= 1.3.4"

  s.add_dependency('nokogiri')
  #s.add_dependency('progressbar')

end
