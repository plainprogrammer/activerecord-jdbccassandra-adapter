warn "Jdbc-Cassandra is only for use with JRuby" if (JRUBY_VERSION.nil? rescue true)
require 'jdbc/cassandra/version'

module Jdbc
  module Cassandra
    def self.dependencies
      %W{cassandra-thrift-#{DRIVER_VERSION}.jar
         cassandra-clientutil-#{DRIVER_VERSION}.jar
         log4j-1.2.16.jar
         slf4j-api-1.7.2.jar
         slf4j-log4j12-1.7.2.jar
         libthrift-0.7.0.jar
         guava-14.0.1.jar
      }
    end

    def self.driver_jar
      "cassandra-jdbc-#{DRIVER_VERSION}.jar"
    end

    def self.load_driver(method = :load)
      dependencies.each {|dependency| send method, dependency}
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
