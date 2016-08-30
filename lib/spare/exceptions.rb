require 'active_record'
module ActiveRecord
  class StoredProcedureNotFound < StandardError; end
  class StoredProcedureNotExecuted < RecordNotSaved;end
end
