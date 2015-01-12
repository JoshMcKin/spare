module Spare
  module Attributes
    def columns
      @columns ||= stored_procedure[:param_list].map do |col|
        col = col.dup
        col.primary = false
        col
      end
    end
  end
end
