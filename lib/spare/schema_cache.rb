require 'active_record/connection_adapters/schema_cache'
module ActiveRecord
  module ConnectionAdapters
    class SchemaCache
      # Get the stored procedure
      def stored_procedure(sp_name)
        @stored_procedure ||= {}
        @stored_procedure[sp_name] ||= connection.stored_procedure(sp_name)
      end
    end
  end
end