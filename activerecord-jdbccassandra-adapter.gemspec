# -*- encoding: utf-8 -*-
arjdbc_lib = File.expand_path("../../lib", __FILE__)
$:.push arjdbc_lib unless $:.include?(arjdbc_lib)
require 'arjdbc/version'

Gem::Specification.new do |s|
  s.name        = "activerecord-jdbccassandra-adapter"
  s.version     = version = ArJdbc::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["James Thompson"]
  spec.email    = ["james@plainprograms.com"]
  spec.license  = "MIT"
  s.description = %q{Install this gem to use Cassandra with JRuby on Rails.}
  s.files = [
    "Rakefile",
    "README.txt",
    "LICENSE.txt",
    "lib/active_record/connection_adapters/jdbccassandra_adapter.rb"
  ]
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  s.homepage = %q{https://github.com/plainprogrammer/activerecord-jdbccassandra-adapter}
  s.require_paths = ["lib"]
  s.summary = %q{Cassandra JDBC adapter for JRuby on Rails.}

  s.add_dependency 'activerecord-jdbc-adapter', "~>#{version}"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
