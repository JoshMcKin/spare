require 'spare/exceptions'
require 'active_record/connection_adapters/abstract_mysql_adapter'
module ActiveRecord
  module ConnectionAdapters
    class AbstractMysqlAdapter < AbstractAdapter

      unless ActiveRecord::VERSION::MAJOR == 4 && ActiveRecord::VERSION::MINOR > 1
        NATIVE_DATABASE_TYPES[:primary_key] = "int(11) auto_increment PRIMARY KEY"
      end

      # Returns hash describing the stored procedure.
      def stored_procedure(name)#:nodoc:
        sp_name = name.split('.').reverse

        sql = "SELECT db,specific_name,param_list,db_collation FROM mysql.proc WHERE specific_name = #{quote(sp_name[0])}"
        sql << " AND db = #{quote(sp_name[1])}" if sp_name[1]

        result = execute(sql)
        keys = result.fields.collect{|k| k.to_sym}
        values = result.to_a[0]
        raise ActiveRecord::StoredProcedureNotFound, "#{name} was not found" unless values
        sp = Hash[keys.zip(values)]
        sp[:param_list] = stored_procedure_params(sp[:param_list], sp[:db_collation])
        sp
      end

      # Consider adding the AbstractAdapter::Column when exploring postgres integration
      class AbstractMysqlAdapter::Column
        attr_accessor :param_type
      end

      def stored_procedure_params(param_list,collation)
        params = []
        param_list = param_list.to_s.split("\n").collect{ |r| r.gsub(/\s+/, ' ').strip.split(" ")}
        param_list.delete([])
        param_list.each do |param|
          param_type = param[0].upcase
          field_name = param[1].to_s.underscore #set_field_encoding(param[1])
          sql_type = param[2]

          if ActiveRecord::VERSION::MAJOR == 4 && ActiveRecord::VERSION::MINOR > 1
            cast_type = lookup_cast_type(sql_type)
            column = new_column(field_name, nil, cast_type, sql_type, true, collation, nil)
          else
            column = new_column(field_name, nil, sql_type, false, collation)
          end

          column.param_type = param_type
          params << column
        end
        params
      end

      def stored_procedure_to_sql(sp)
        sql = []
        sql << sp_inout_sql(sp)
        sql << sp_call_sql(sp)
        sql << sp_out_sql(sp)
        sql.compact!
        sql.join("\n")
      end

      def execute_stored_procedure(sp)
        call_results = execute(stored_procedure_to_sql(sp))

        clnt = instance_variable_get(:@connection)
        while clnt.next_result
          if result_array = clnt.store_result.to_a[0]
            sp_out_params(sp).length != 0
            sp_out_params(sp).each_with_index do |param,i|
              sp.__send__ "#{param.name}=", result_array[i]
            end
          end
        end

        call_results
      end

      private

      def sp_in_params(sp)
        prms = []
        sp.class.stored_procedure[:param_list].each do |param|
          if param.param_type == "IN"
            prms << quote(sp.read_attribute(param.name))
          else # OUT
            prms << "@#{param.name}"
          end
        end
        prms
      end

      def sp_out_params(sp)
        sp.class.stored_procedure[:param_list].select { |param| param.param_type.to_s =~ /out/i }
      end

      def sp_inout_params(sp)
        sp.class.stored_procedure[:param_list].select { |param| param.param_type.to_s =~ /inout/i }
      end

      def sp_out_sql(sp)
        out_vars = sp_out_params(sp).map{|param| "@#{param.name}"}.join(',')
        if !out_vars.blank?
          "SELECT #{sp_out_params(sp).map{|param| "@#{param.name}"}.join(',')};"
        end
      end

      # In MySQL even with multi-statements flag set, variables must be set 1 at a time, so return an array
      def sp_inout_sql(sp)
        sql = []
        sp_inout_params(sp).each do |param|
          sql << "SET @#{param.name} = #{quote(sp.send(param.name))};"
        end
        sql
      end

      def sp_call_sql(sp)
        "CALL #{sp.class.stored_procedure[:db]}.#{sp.class.stored_procedure[:specific_name]}(#{sp_in_params(sp).join(',')});"
      end
    end
  end
end
