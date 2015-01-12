module Spare
  module ModelSchema

    def schema
      table_name_prefix
    end

    def schema=schema
      self.table_name_prefix = schema
    end

    def stored_procedure
      connection.schema_cache.stored_procedure(self.stored_procedure_name)
    end

    def stored_procedure_name=stored_procedure_name
      self.table_name=stored_procedure_name
    end

    def stored_procedure_name
      table_name
    end
  end
end
