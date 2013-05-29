# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'arjdbc/cassandra/version'

Gem::Specification.new do |s|
  s.name        = "activerecord-jdbccassandra-adapter"
  s.version     = version = ArJdbc::Cassandra::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors = ['James Thompson']
  s.description = %q{Install this gem to use Cassandra with JRuby on Rails.}
  s.email = ['james@plainprograms.com']
  s.files = [
      "Rakefile",
      "README.md",
      "LICENSE.txt",
      "lib/active_record/connection_adapters/jdbccassandra_adapter.rb",
      "lib/arjdbc/cassandra/version"
  ]
  s.homepage = %q{https://github.com/plainprogrammer/activerecord-jdbccassandra-adapter}
  s.require_paths = ["lib"]
  s.rubyforge_project = ''
  s.summary = %q{Cassandra JDBC adapter for JRuby on Rails.}

  s.add_dependency 'activerecord-jdbc-adapter', '~> 1.2.0'
  s.add_dependency 'jdbc-cassandra', '~> 1.2.5'
end
