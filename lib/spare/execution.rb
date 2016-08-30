module Spare
  module Execution
    module ClassMethods
      # Build an object (or multiple objects) and executes, if validations pass.
      # The resulting object is returned whether the object was executed successfully to the database or not.
      #
      # The +attributes+ parameter can be either a Hash or an Array of Hashes. These Hashes describe the
      # attributes on the objects that are to be created.
      def execute(attributes = nil)
        if attributes.is_a?(Array)
          attributes.map { |attr| excute(attr) }
        else
          object = new(attributes)
          object.execute
          object
        end
      end
      alias :call :execute

     # Build an object (or multiple objects) and executes,
     # if validations pass. Raises a RecordInvalid error if validations fail,
     # unlike Base#create.
     #
     # The +attributes+ parameter can be either a Hash or an Array of Hashes.
     # These describe which attributes to be created on the object, or
     # multiple objects when given an Array of Hashes.
      def execute!(attributes = nil)
        if attributes.is_a?(Array)
          attributes.collect { |attr| create!(attr) }
        else
          object = new(attributes)
          object.execute!
          object
        end
      end
      alias :call! :execute!
    end

    attr_accessor :call_results

    def execute
      if valid?
        self.class.connection_pool.with_connection do |conn|
          call_results = conn.execute_stored_procedure(self)
        end
      end
      valid?
    end
    alias :call :execute

    def execute!
      unless valid?
        raise(ActiveRecord::StoredProcedureNotExecuted.new("Failed to execute the stored procedure", self))
      end
    end
    alias :call! :execute!

    def self.included(base)
      base.extend(Spare::Execution::ClassMethods)
    end
  end
end
