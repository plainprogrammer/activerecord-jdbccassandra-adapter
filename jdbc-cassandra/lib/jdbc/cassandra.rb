warn "Jdbc-Cassandra is only for use with JRuby" if (JRUBY_VERSION.nil? rescue true)
require 'jdbc/cassandra/version'

module Jdbc
  module Cassandra
    DRIVER_VERSION = '1.2.5'
    VERSION = DRIVER_VERSION + ''

    def self.driver_jar
      "cassandra-jdbc-#{DRIVER_VERSION}.jar"
    end

    def self.load_driver(method = :load)
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
