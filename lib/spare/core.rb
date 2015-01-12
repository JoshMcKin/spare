module Spare
  module Core
    # Returns a string like 'MyStoredProcedure(p_id:integer, p_title:string, p_body:text)'
    def inspect
      if self == Base
        super
      elsif abstract_class?
        super
      elsif table_exists?
        super
      else
        "#{name}(Stored procedure doesn't exist)"
      end
    end
    #########################
  end
end
