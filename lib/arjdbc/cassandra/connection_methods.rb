ArJdbc::ConnectionMethods.module_eval do
  def cassandra_connection(config)
    begin
      require 'jdbc/cassandra'
      ::Jdbc::Cassandra.load_driver(:require) if defined?(::Jdbc::Cassandra.load_driver)
    rescue LoadError # assuming driver.jar is on the class-path
    end

    config[:port] ||= 9106
    config[:url] ||= "jdbc:cassandra://#{config[:host]}:#{config[:port]}/#{config[:database]}"
    config[:driver] ||= defined?(::Jdbc::Cassandra.driver_name) ? ::Jdbc::Cassandra.driver_name : 'org.apache.cassandra.cql.jdbc.CassandraDriver'
    config[:adapter_spec] ||= ::ArJdbc::Cassandra
    config[:adapter_class] = ActiveRecord::ConnectionAdapters::CassandraAdapter unless config.key?(:adapter_class)
    # config[:connection_alive_sql] ||= 'SELECT 1'
    
    options = (config[:options] ||= {})
    options['zeroDateTimeBehavior'] ||= 'convertToNull'
    options['jdbcCompliantTruncation'] ||= 'false'
    options['useUnicode'] ||= 'true'
    options['characterEncoding'] = config[:encoding] || 'utf8'
    
    connection = jdbc_connection(config)
    ::ArJdbc::Cassandra.kill_cancel_timer(connection.raw_connection)
    connection
  end
  alias_method :jdbccassandra_connection, :cassandra_connection
end