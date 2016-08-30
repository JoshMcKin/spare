require "active_record"
module ActiveRecord

  # TODO - Refactor using only those modules necessary for things to work, should
  # be a lot easier when updated to support only Rails 4. Also, move any methods here
  # to their own module
  class StoredProcedure < Base

    extend Spare::Core
    extend Spare::ModelSchema
    extend Spare::Attributes
    include Spare::Execution

    self.pluralize_table_names = false # Stored procedure names are what they are.
    self.abstract_class = true

    attr_accessor :call_results

    def to_sql(skip_valid=false)
      if skip_valid || valid?
        self.class.connection.stored_procedure_to_sql(self)
      end
    end
  end
end
