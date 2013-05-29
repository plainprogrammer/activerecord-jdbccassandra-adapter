class ActiveRecord::Base
  class << self
    def cassandra_connection(config)
      begin
        require 'jdbc/cassandra'
        ::Jdbc::MySQL.load_driver(:require) if defined?(::Jdbc::Cassandra.load_driver)
      rescue LoadError # assuming driver.jar is on the class-path
      end

      config[:port] ||= 9160
      config[:url] ||= "jdbc:cassandra://#{config[:host]}:#{config[:port]}/#{config[:database]}"
      config[:driver] ||= defined?(::Jdbc::Cassandra.driver_name) ? ::Jdbc::Cassandra.driver_name : 'org.apache.cassandra.cql.jdbc.CassandraDriver'
      config[:adapter_class] = ActiveRecord::ConnectionAdapters::CassandraAdapter
      config[:adapter_spec] = ::ArJdbc::Cassandra

      options = (config[:options] ||= {})
      #options['zeroDateTimeBehavior'] ||= 'convertToNull'
      #options['jdbcCompliantTruncation'] ||= 'false'
      #options['useUnicode'] ||= 'true'
      #options['characterEncoding'] = config[:encoding] || 'utf8'

      jdbc_connection(config)
    end
    alias_method :jdbccassandra_connection, :cassandra_connection
  end
end
