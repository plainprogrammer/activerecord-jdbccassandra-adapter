module ActiveRecord
  module ConnectionAdapters
    class CassandraJdbcConnection < JdbcConnection
      def set_native_database_types
        @native_types = {}
      end
      alias :java_native_database_types :set_native_database_types
    end
  end
end
