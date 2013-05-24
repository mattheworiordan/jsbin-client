# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "jsbin-client/version"

Gem::Specification.new do |s|
  s.name        = "jsbin-client"
  s.version     = JsBinClient::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Matthew O'Riordan"]
  s.email       = ["matthew.oriordan@gmail.com"]
  s.homepage    = "http://github.com/mattheworiordan/jsbin-client"
  s.summary     = %q{A simple API client for JSBin}
  s.description = %q{Provides methods to add, update, create revisions of bins and obtain bin preview URLs}

  s.rubyforge_project = "jsbin-client"

  s.add_dependency 'rest-client', '>= 1.6'

  s.add_development_dependency 'rspec', '~> 2.7'
  s.add_development_dependency 'webmock', '~> 1.11'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {spec}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
