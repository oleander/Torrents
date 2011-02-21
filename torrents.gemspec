# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "torrents"
  s.version     = "0.0.1"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Linus Oleander"]
  s.email       = ["linus@oleander.nu"]
  s.homepage    = "https://github.com/oleander/Torrents"
  s.summary     = %q{Search and download torrents from your favorite bittorrent tracker}
  s.description = %q{Search and download torrents from your favorite bittorrent tracker using Ruby}

  s.rubyforge_project = "torrents"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_dependency('rest-client')
  s.add_dependency('nokogiri')
  s.add_dependency('rchardet19')
  s.add_dependency('classify', '~> 0.0.3')
  
  s.add_development_dependency('rspec')
  s.add_development_dependency('autotest-standalone')
  s.add_development_dependency('autotest')
  s.add_development_dependency('autotest-growl')
  s.add_development_dependency('autotest-fsevent')
end
