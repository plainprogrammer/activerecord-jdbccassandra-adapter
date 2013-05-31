module ArJdbc
  module Cassandra
    module DatabaseStatements
      # Converts an arel AST to SQL
      def to_sql(arel, binds = [])
        if arel.respond_to?(:ast)
          visitor.accept(arel.ast) do
            quote(*binds.shift.reverse)
          end
        else
          arel
        end
      end

      # Returns an array of record hashes with the column names as keys and
      # column values as values.
      def select_all(arel, name = nil, binds = [])
        select(to_sql(arel, binds), name, binds)
      end

      # Returns a record hash with the column names as keys and column values
      # as values.
      def select_one(arel, name = nil)
        result = select_all(arel, name)
        result.first if result
      end

      # Returns a single value from a record
      def select_value(arel, name = nil)
        if result = select_one(arel, name)
          result.values.first
        end
      end

      # Returns an array of the values of the first column in a select:
      #   select_values("SELECT id FROM companies LIMIT 3") => [1,2,3]
      def select_values(arel, name = nil)
        result = select_rows(to_sql(arel, []), name)
        result.map { |v| v[0] }
      end

      # Returns an array of arrays containing the field values.
      # Order is the same as that returned by +columns+.
      #def select_rows(sql, name = nil)
      #end
      #undef_method :select_rows

      # Executes the SQL statement in the context of this connection.
      #def execute(sql, name = nil)
      #end
      #undef_method :execute

      # Executes +sql+ statement in the context of this connection using
      # +binds+ as the bind substitutes. +name+ is logged along with
      # the executed +sql+ statement.
      #def exec_query(sql, name = 'SQL', binds = [])
      #end

      # Executes insert +sql+ statement in the context of this connection using
      # +binds+ as the bind substitutes. +name+ is the logged along with
      # the executed +sql+ statement.
      def exec_insert(sql, name, binds)
        exec_query(sql, name, binds)
      end
      alias :exec_update :exec_insert
      #alias :exec_delete :exec_insert

      # Executes delete +sql+ statement in the context of this connection using
      # +binds+ as the bind substitutes. +name+ is the logged along with
      # the executed +sql+ statement.
      def exec_delete(sql, name, binds)
        exec_query(sql, name, binds)
      end

      # Executes update +sql+ statement in the context of this connection using
      # +binds+ as the bind substitutes. +name+ is the logged along with
      # the executed +sql+ statement.
      #def exec_update(sql, name, binds)
      #  exec_query(sql, name, binds)
      #end

      # Returns the last auto-generated ID from the affected table.
      #
      # +id_value+ will be returned unless the value is nil, in
      # which case the database will attempt to calculate the last inserted
      # id and return that value.
      #
      # If the next id was calculated in advance (as in Oracle), it should be
      # passed in as +id_value+.
      def insert(arel, name = nil, pk = nil, id_value = nil, sequence_name = nil, binds = [])
        sql, binds = sql_for_insert(to_sql(arel, binds), pk, id_value, sequence_name, binds)
        value      = exec_insert(sql, name, binds)
        id_value || last_inserted_id(value)
      end

      # Executes the update statement and returns the number of rows affected.
      def update(arel, name = nil, binds = [])
        exec_update(to_sql(arel, binds), name, binds)
      end

      # Executes the delete statement and returns the number of rows affected.
      def delete(arel, name = nil, binds = [])
        exec_delete(to_sql(arel, binds), name, binds)
      end

      # Checks whether there is currently no transaction active. This is done
      # by querying the database driver, and does not use the transaction
      # house-keeping information recorded by #increment_open_transactions and
      # friends.
      #
      # Returns true if there is no transaction active, false if there is a
      # transaction active, and nil if this information is unknown.
      #
      # Not all adapters supports transaction state introspection. Currently,
      # only the PostgreSQL adapter supports this.
      def outside_transaction?
        nil
      end

      # Returns +true+ when the connection adapter supports prepared statement
      # caching, otherwise returns +false+
      def supports_statement_cache?
        false
      end

      def default_sequence_name(table, column)
        nil
      end

      # Set the sequence to the max value of the table's column.
      def reset_sequence!(table, column, sequence = nil)
        # Do nothing by default. Implement for PostgreSQL, Oracle, ...
      end

      # Inserts the given fixture into the table. Overridden in adapters that require
      # something beyond a simple insert (eg. Oracle).
      def insert_fixture(fixture, table_name)
        columns = schema_cache.columns_hash(table_name)

        key_list   = []
        value_list = fixture.map do |name, value|
          key_list << quote_column_name(name)
          quote(value, columns[name])
        end

        execute "INSERT INTO #{quote_table_name(table_name)} (#{key_list.join(', ')}) VALUES (#{value_list.join(', ')})", 'Fixture Insert'
      end

      def case_sensitive_equality_operator
        "="
      end

      def limited_update_conditions(where_sql, quoted_table_name, quoted_primary_key)
        "WHERE #{quoted_primary_key} IN (SELECT #{quoted_primary_key} FROM #{quoted_table_name} #{where_sql})"
      end

      # Sanitizes the given LIMIT parameter in order to prevent SQL injection.
      #
      # The +limit+ may be anything that can evaluate to a string via #to_s. It
      # should look like an integer, or a comma-delimited list of integers, or
      # an Arel SQL literal.
      #
      # Returns Integer and Arel::Nodes::SqlLiteral limits as is.
      # Returns the sanitized limit parameter, either as an integer, or as a
      # string which contains a comma-delimited list of integers.
      def sanitize_limit(limit)
        if limit.is_a?(Integer) || limit.is_a?(Arel::Nodes::SqlLiteral)
          limit
        elsif limit.to_s =~ /,/
          Arel.sql limit.to_s.split(',').map{ |i| Integer(i) }.join(',')
        else
          Integer(limit)
        end
      end

      # The default strategy for an UPDATE with joins is to use a subquery. This doesn't work
      # on mysql (even when aliasing the tables), but mysql allows using JOIN directly in
      # an UPDATE statement, so in the mysql adapters we redefine this to do that.
      def join_to_update(update, select) #:nodoc:
        subselect = select.clone
        subselect.projections = [update.key]

        update.where update.key.in(subselect)
      end

      protected
      # Returns an array of record hashes with the column names as keys and
      # column values as values.
      def select(sql, name = nil, binds = [])
        execute(sql, name)
      end
      undef_method :select

      # Returns the last auto-generated ID from the affected table.
      def insert_sql(sql, name = nil, pk = nil, id_value = nil, sequence_name = nil)
        execute(sql, name)
        id_value
      end

      # Executes the update statement and returns the number of rows affected.
      def update_sql(sql, name = nil)
        execute(sql, name)
      end

      # Executes the delete statement and returns the number of rows affected.
      def delete_sql(sql, name = nil)
        update_sql(sql, name)
      end

      def sql_for_insert(sql, pk, id_value, sequence_name, binds)
        [sql, binds]
      end

      def last_inserted_id(result)
        row = result.rows.first
        row && row.first
      end
    end
  end
end
