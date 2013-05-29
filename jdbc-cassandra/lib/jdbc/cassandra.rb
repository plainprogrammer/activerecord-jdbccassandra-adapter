warn "Jdbc-Cassandra is only for use with JRuby" if (JRUBY_VERSION.nil? rescue true)
require 'jdbc/cassandra/version'

require 'cassandra-clientutil-1.2.5.jar'
require 'cassandra-thrift-1.2.5.jar'

module Jdbc
  module Cassandra
    def self.driver_jar
      "cassandra-jdbc-#{DRIVER_VERSION}.jar"
    end

    def self.load_driver(method = :require)
      send method, driver_jar
    end

    def self.driver_name
      'org.apache.cassandra.cql.jdbc.CassandraDriver'
    end

    if defined?(JRUBY_VERSION) && # enable backwards-compat behavior :
        ( Java::JavaLang::Boolean.get_boolean("jdbc.driver.autoload") ||
            Java::JavaLang::Boolean.get_boolean("jdbc.cassandra.autoload") )
      warn "autoloading JDBC driver on require 'jdbc/cassandra'" if $VERBOSE
      load_driver :require
    end
  end
end
