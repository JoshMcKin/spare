require "active_record"
module ActiveRecord

  # TODO - Refactor using only those modules necessary for things to work, should
  # be a lot easier when updated to support only Rails 4. Also, move any methods here 
  # to their own module
  class StoredProcedure < Base

    extend Spare::Core
    extend Spare::ModelSchema
    extend Spare::Attributes

    self.pluralize_table_names = false # Stored procedure names are what they are.
    self.abstract_class = true

    attr_accessor :call_results

    def in_params
      @in_params ||= in_fetch_params
    end

    def in_fetch_params
      prms = []
      self.class.stored_procedure[:param_list].each do |param|
        if param.param_type == "IN"
          prms << self.class.connection.quote(self.send(param.name.to_sym))
        else # OUT
          prms << "@#{param.name}"
        end
      end
      prms
    end

    def out_params
      @out_params ||= self.class.stored_procedure[:param_list].select{|param| param.param_type.to_s =~ /out/i}
    end

    def inout_params
      @inout_params ||= self.class.stored_procedure[:param_list].select{|param| param.param_type.to_s =~ /inout/i}
    end

    def out_sql
      "SELECT #{out_params.collect{|param| "@#{param.name}"}.join(',')};"
    end

    # In MySQL even with multi-statements flag set variables must be set 1 at a time, so return an array
    def inout_sql
      sql = []
      inout_params.each do |param|
        sql << "SET @#{param.name} = #{connection.quote(send(param.name))}"
      end
      sql
    end

    def call_sql
      "CALL #{self.class.stored_procedure[:db]}.#{self.class.stored_procedure[:specific_name]}(#{in_params.join(',')});"
    end

    def to_sql(skip_valid=false)
      if skip_valid || valid?
        # sql = (inout_sql.blank? ? "" : inout_sql)
        sql = call_sql
        sql << out_sql unless out_params.blank?
        sql
      end
    end

    def execute
      if valid?
        conn = self.class.connection
        unless inout_params.blank?
          self.inout_sql.each do |inout_to_set|
            conn.execute(inout_to_set)
          end
        end
        self.call_results = conn.execute(self.to_sql(true))
        if out_params.length != 0
          clnt = conn.instance_variable_get(:@connection)
          while clnt.next_result
            result_array = clnt.store_result.to_a[0]
            out_params.each_with_index do |param,i|
              send "#{param.name}=", result_array[i]
            end
          end
        end
      end
      valid?
    end
  end
end
