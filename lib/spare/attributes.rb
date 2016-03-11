module Spare
  module Attributes
    def columns
      @columns ||= stored_procedure[:param_list].map do |col|
        col = col.dup
        col.primary = false if ActiveRecord::VERSION::MAJOR == 3 
        col
      end
    end
  end
end
