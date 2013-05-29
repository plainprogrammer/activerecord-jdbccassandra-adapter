# -*- encoding: utf-8 -*-
$:.push File.expand_path(File.join(__FILE__, '..', 'lib'))
require 'active_record/jdbccassandra/adapter/version'

Gem::Specification.new do |s|
  s.name        = "activerecord-jdbccassandra-adapter"
  s.version     = ActiveRecord::JdbcCassandra::Adapter::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["James Thompson"]
  s.email       = ["james@plainprograms.com"]
  s.license     = "MIT"
  s.description = %q{Install this gem to use Cassandra with JRuby on Rails.}
  s.files = [
    "Rakefile",
    "README.md",
    "LICENSE.txt",
    "lib/active_record/connection_adapters/jdbccassandra_adapter.rb"
  ]
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.homepage      = %q{https://github.com/plainprogrammer/activerecord-jdbccassandra-adapter}
  s.require_paths = ["lib"]
  s.summary       = %q{Cassandra JDBC adapter for JRuby on Rails.}

  s.add_dependency 'activerecord-jdbc-adapter'

  s.add_development_dependency "bundler", "~> 1.3"
  s.add_development_dependency "rake"
end
