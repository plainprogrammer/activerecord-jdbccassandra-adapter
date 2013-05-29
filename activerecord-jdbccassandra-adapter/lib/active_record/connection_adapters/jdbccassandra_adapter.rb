# NOTE: required by AR resolver with 'jdbccassandra' adapter configuration :
# require "active_record/connection_adapters/#{spec[:adapter]}_adapter"
# we should make sure a jdbccassandr_connection is setup on ActiveRecord::Base
require 'arjdbc/cassandra'
# all setup should be performed in arjdbc/cassandra to avoid circular requires
# this should not be required from any loads performed by arjdbc/cassandra code
