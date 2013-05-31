module Cassandra # :nodoc:
  remove_const(:Error) if const_defined?(:Error)

  class Error < ::ActiveRecord::JDBCError; end

  def self.client_version
    10205 # faked out for AR tests
  end
end
