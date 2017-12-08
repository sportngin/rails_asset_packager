# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "rails_asset_packager/version"

Gem::Specification.new do |s|
  s.name        = "rails_asset_packager"
  s.version     = RailsAssetPackager::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Scott Becker","Katherine G Pe","James Thompson"]
  s.email       = ["","","james@plainprograms.com"]
  s.homepage    = "http://rubygems.org/gems/rails_asset_packager"
  s.summary     = %q{Javascript and CSS asset compression for Rails}
  s.description = %q{A tool to compress Javascript and CSS assets for production Rals applications.}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "aws-s3", "~> 0.6.3"
  s.add_dependency "uglifier", ">= 2.7.2"

  s.add_development_dependency "test-unit"
  s.add_development_dependency "mocha"
end
