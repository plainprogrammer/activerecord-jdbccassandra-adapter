class ActiveRecord::ConnectionAdapters::CassandraJdbcConnection < ActiveRecord::ConnectionAdapters::JdbcConnection
  alias :java_native_database_types :set_native_database_types

  # Cassandra doesn't support doing this the way the Java code tries to.
  def set_native_database_types
    @native_types = {}
  end
end

module ArJdbc
  module Cassandra
    def self.extended(adapter)
      adapter.configure_connection
    end

    #def configure_connection
    #  execute("SET SQL_AUTO_IS_NULL=0")
    #end

    def self.column_selector
      [ /cassandra/i, lambda { |_,column| column.extend(::ArJdbc::Cassandra::Column) } ]
    end

    def self.jdbc_connection_class
      ::ActiveRecord::ConnectionAdapters::CassandraJdbcConnection
    end

    module Column

    end

    ColumnExtensions = Column # :nodoc: backwards-compatibility

    NATIVE_DATABASE_TYPES = {
      :primary_key  => 'uuid PRIMARY KEY',
      :string       => { :name => 'varchar' },
      :text         => { :name => 'text' },
      :integer      => { :name => 'int' },
      :float        => { :name => 'float' },
      :decimal      => { :name => 'decimal' },
      :datetime     => { :name => 'timestamp' },
      :timestamp    => { :name => 'timestamp' },
      :time         => { :name => 'timestamp' },
      :date         => { :name => 'timestamp' },
      :binary       => { :name => 'blob' },
      :boolean      => { :name => 'boolean' },
      # EXTENDED SUPPORT FOR NATIVE TYPES
      :ascii        => { :name => 'ascii' },
      :bigint       => { :name => 'bigint' },
      :blob         => { :name => 'blob' },
      :counter      => { :name => 'counter' },
      :double       => { :name => 'double' },
      :inet         => { :name => 'inet' },
      :timeuuid     => { :name => 'timeuuid' },
      :uuid         => { :name => 'uuid' },
      :varchar      => { :name => 'varchar' },
      :varint       => { :name => 'varint' }
    }

    def native_database_types
      NATIVE_DATABASE_TYPES
    end

    ADAPTER_NAME = 'Cassandra'.freeze

    def adapter_name #:nodoc:
      ADAPTER_NAME
    end

    def self.arel2_visitors(config)
      {
          'cassandra' => ::Arel::Visitors::ToSql,
          'jdbccassandra' => ::Arel::Visitors::ToSql
      }
    end

    def case_sensitive_modifier(node)
      Arel::Nodes::Bin.new(node)
    end

    def limited_update_conditions(where_sql, quoted_table_name, quoted_primary_key)
      where_sql
    end

    def supports_migrations?
      false
    end

    def supports_primary_key? # :nodoc:
      true
    end

    def supports_bulk_alter? # :nodoc:
      false
    end

    def supports_index_sort_order? # :nodoc:
      false
    end

    def supports_transaction_isolation? # :nodoc:
      false
    end

    def supports_views? # :nodoc:
      false
    end

    def supports_savepoints? # :nodoc:
      false
    end

    # DATABASE STATEMENTS ======================================

    def exec_insert(sql, name, binds)
      execute sql, name, binds
    end
    alias :exec_update :exec_insert
    alias :exec_delete :exec_insert

    # SCHEMA STATEMENTS ========================================

    def structure_dump #:nodoc:
      execute('DESCRIBE SCHEMA')
    end

    def recreate_database(name, options = {}) #:nodoc:
      drop_database(name)
      create_database(name, options)
    end

    def create_database(name, options = {}) #:nodoc:
      query = "CREATE KEYSPACE #{name} WITH strategy_class = #{options[:strategy_class] || 'SimpleStrategy'}"

      if options[:strategy_options]
        if options[:strategy_options].is_a?(Array)
          options[:strategy_options].each do |strategy_option|
            query += " AND strategy_options:#{strategy_option}"
          end
        else
          query += " AND strategy_options:#{options[:strategy_options]}"
        end
      end

      execute query
    end

    def drop_database(name) #:nodoc:
      execute "DROP KEYSPACE #{name}"
    end

    #def create_table(name, options = {}) #:nodoc:
    #  super(name, {:options => "ENGINE=InnoDB DEFAULT CHARSET=utf8"}.merge(options))
    #end

    def drop_table(name) #:nodoc:
      execute "DROP TABLE #{name}"
    end

    #def rename_table(name, new_name)
    #  execute "RENAME TABLE #{quote_table_name(name)} TO #{quote_table_name(new_name)}"
    #end

    #def remove_index!(table_name, index_name) #:nodoc:
    #                                          # missing table_name quoting in AR-2.3
    #  execute "DROP INDEX #{quote_column_name(index_name)} ON #{quote_table_name(table_name)}"
    #end

    #def add_column(table_name, column_name, type, options = {})
    #  add_column_sql = "ALTER TABLE #{quote_table_name(table_name)} ADD #{quote_column_name(column_name)} #{type_to_sql(type, options[:limit], options[:precision], options[:scale])}"
    #  add_column_options!(add_column_sql, options)
    #  add_column_position!(add_column_sql, options)
    #  execute(add_column_sql)
    #end

    #def change_column_default(table_name, column_name, default) #:nodoc:
    #  column = column_for(table_name, column_name)
    #  change_column table_name, column_name, column.sql_type, :default => default
    #end

    #def change_column_null(table_name, column_name, null, default = nil)
    #  column = column_for(table_name, column_name)
    #
    #  unless null || default.nil?
    #    execute("UPDATE #{quote_table_name(table_name)} SET #{quote_column_name(column_name)}=#{quote(default)} WHERE #{quote_column_name(column_name)} IS NULL")
    #  end
    #
    #  change_column table_name, column_name, column.sql_type, :null => null
    #end

    #def change_column(table_name, column_name, type, options = {}) #:nodoc:
    #  column = column_for(table_name, column_name)
    #
    #  unless options_include_default?(options)
    #    options[:default] = column.default
    #  end
    #
    #  unless options.has_key?(:null)
    #    options[:null] = column.null
    #  end
    #
    #  change_column_sql = "ALTER TABLE #{quote_table_name(table_name)} CHANGE #{quote_column_name(column_name)} #{quote_column_name(column_name)} #{type_to_sql(type, options[:limit], options[:precision], options[:scale])}"
    #  add_column_options!(change_column_sql, options)
    #  add_column_position!(change_column_sql, options)
    #  execute(change_column_sql)
    #end

    #def rename_column(table_name, column_name, new_column_name) #:nodoc:
    #  options = {}
    #  if column = columns(table_name).find { |c| c.name == column_name.to_s }
    #    options[:default] = column.default
    #    options[:null] = column.null
    #  else
    #    raise ActiveRecord::ActiveRecordError, "No such column: #{table_name}.#{column_name}"
    #  end
    #  current_type = select_one("SHOW COLUMNS FROM #{quote_table_name(table_name)} LIKE '#{column_name}'")["Type"]
    #  rename_column_sql = "ALTER TABLE #{quote_table_name(table_name)} CHANGE #{quote_column_name(column_name)} #{quote_column_name(new_column_name)} #{current_type}"
    #  add_column_options!(rename_column_sql, options)
    #  execute(rename_column_sql)
    #end

    #def add_limit_offset!(sql, options) #:nodoc:
    #  limit, offset = options[:limit], options[:offset]
    #  if limit && offset
    #    sql << " LIMIT #{offset.to_i}, #{sanitize_limit(limit)}"
    #  elsif limit
    #    sql << " LIMIT #{sanitize_limit(limit)}"
    #  elsif offset
    #    sql << " OFFSET #{offset.to_i}"
    #  end
    #  sql
    #end

    #def type_to_sql(type, limit = nil, precision = nil, scale = nil)
    #  case type.to_s
    #    when 'binary'
    #      case limit
    #        when 0..0xfff; "varbinary(#{limit})"
    #        when nil; "blob"
    #        when 0x1000..0xffffffff; "blob(#{limit})"
    #        else raise(ActiveRecordError, "No binary type has character length #{limit}")
    #      end
    #    when 'integer'
    #      case limit
    #        when 1; 'tinyint'
    #        when 2; 'smallint'
    #        when 3; 'mediumint'
    #        when nil, 4, 11; 'int(11)' # compatibility with MySQL default
    #        when 5..8; 'bigint'
    #        else raise(ActiveRecordError, "No integer type has byte size #{limit}")
    #      end
    #    when 'text'
    #      case limit
    #        when 0..0xff; 'tinytext'
    #        when nil, 0x100..0xffff; 'text'
    #        when 0x10000..0xffffff; 'mediumtext'
    #        when 0x1000000..0xffffffff; 'longtext'
    #        else raise(ActiveRecordError, "No text type has character length #{limit}")
    #      end
    #    else
    #      super
    #  end
    #end

    #def add_column_position!(sql, options)
    #  if options[:first]
    #    sql << " FIRST"
    #  elsif options[:after]
    #    sql << " AFTER #{quote_column_name(options[:after])}"
    #  end
    #end
  end
end

module ActiveRecord
  module ConnectionAdapters
    # Remove any vestiges of core/Ruby MySQL adapter
    remove_const(:CassandraColumn) if const_defined?(:CassandraColumn)
    remove_const(:CassandraAdapter) if const_defined?(:CassandraAdapter)

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

    class CassandraAdapter < JdbcAdapter
      include ::ArJdbc::Cassandra
      #include ::ArJdbc::Cassandra::ExplainSupport

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

# Don't need to load native mysql adapter
#$LOADED_FEATURES << 'active_record/connection_adapters/mysql_adapter.rb'
#$LOADED_FEATURES << 'active_record/connection_adapters/mysql2_adapter.rb'

module Cassandra # :nodoc:
  remove_const(:Error) if const_defined?(:Error)
  class Error < ::ActiveRecord::JDBCError; end

  def self.client_version
    10205 # faked out for AR tests
  end
end
