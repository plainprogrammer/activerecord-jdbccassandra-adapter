# -*- encoding: utf-8 -*-

$LOAD_PATH << File.expand_path('../lib', __FILE__)
require 'jdbc/cassandra/version'
version = Jdbc::Cassandra::VERSION
Gem::Specification.new do |s|
  s.name = %q{jdbc-cassandra}
  s.version = version

  s.authors = ['James Thompson']
  s.email = ['james@plainprograms.com']

  s.files = [
      "Rakefile",
      "README.md",
      "LICENSE.txt",
      *Dir["lib/**/*"].to_a
  ]
  s.homepage = %q{https://github.com/plainprogrammer/activerecord-jdbccassandra-adapter}
  s.rdoc_options = ["--main", "README.md"]
  s.require_paths = ["lib"]
  s.rubyforge_project = ''

  s.summary = %q{Cassandra JDBC driver for JRuby and Cassandra/ActiveRecord-JDBC (activerecord-jdbccassandra-adapter).}
  s.description = %q{Install this gem `require 'jdbc/cassandra'` and invoke `Jdbc::Cassandra.load_driver` within JRuby to load the driver.}
end
