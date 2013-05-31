module ArJdbc
  module Cassandra
    module Column; end

    ColumnExtensions = Column # :nodoc: backwards-compatibility
  end
end

module ActiveRecord
  module ConnectionAdapters
    # Make sure we don't interfere with a pure Ruby version
    remove_const(:CassandraColumn) if const_defined?(:CassandraColumn)

    class CassandraColumn < JdbcColumn
      include ::ArJdbc::Cassandra::Column

      def initialize(name, *args)
        if Hash === name
          super
        else
          super(nil, name, *args)
        end
      end

      def call_discovered_column_callbacks(*)
      end
    end
  end
end
