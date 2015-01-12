require 'active_record/connection_adapters/abstract_mysql_adapter'
module ActiveRecord
  module ConnectionAdapters
    class AbstractMysqlAdapter < AbstractAdapter

      # Returns hash describing the stored procedure.
      def stored_procedure(name)#:nodoc:
        name = name.split('.').reverse

        sql = "SELECT db,specific_name,param_list,db_collation FROM mysql.proc WHERE specific_name = #{quote(name[0])}"
        sql << " AND db = #{quote(name[1])}" if name[1]

        result = execute(sql)
        keys = result.fields.collect{|k| k.to_sym}
        values = result.to_a[0]
        return nil unless values
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
          column = new_column(field_name, nil, sql_type, false, collation)
          column.param_type = param_type
          params << column
        end
        params
      end
    end
  end
end
