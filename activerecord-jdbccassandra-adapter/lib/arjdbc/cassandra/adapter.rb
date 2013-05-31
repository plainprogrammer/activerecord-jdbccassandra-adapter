module ActiveRecord
  module ConnectionAdapters
    # Make sure we don't interfere with a pure Ruby version
    remove_const(:CassandraAdapter) if const_defined?(:CassandraAdapter)

    class CassandraAdapter < JdbcAdapter
      include ::ArJdbc::Cassandra

      def jdbc_connection_class(spec)
        ::ArJdbc::Cassandra.jdbc_connection_class
      end

      def jdbc_column_class
        CassandraColumn
      end
      #alias_chained_method :columns, :query_cache, :jdbc_columns

      # some QUOTING caching :

      @@quoted_table_names = {}

      def quote_table_name(name)
        unless quoted = @@quoted_table_names[name]
          quoted = super
          @@quoted_table_names[name] = quoted.freeze
        end
        quoted
      end

      @@quoted_column_names = {}

      def quote_column_name(name)
        unless quoted = @@quoted_column_names[name]
          quoted = super
          @@quoted_column_names[name] = quoted.freeze
        end
        quoted
      end

    end
  end
end
