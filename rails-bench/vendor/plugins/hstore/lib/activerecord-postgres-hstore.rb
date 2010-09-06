class Hstore < Hash
end

class Hash
  def to_hstore
    #@todo DIOGO! Check security issues with this quoting pleaz
    map{|idx,val| "('#{idx}' => '#{val.to_s.gsub(/'/,"''")}')"  }.join(' || ')
  end
  def from_hstore
    self
  end
end
class String
  def to_hstore
    self
  end
  def from_hstore
    Hash[ scan(/"([^"]+)"=>"([^"]+)"/) ]
  end
end

raise defined?(ActiveRecord::ConnectionAdapters::Column).to_s

module ActiveRecord
  class HstoreTypeMismatch < ActiveRecord::ActiveRecordError
  end
  module ConnectionAdapters
    class PostgreSQLColumn < Column
      alias :old_type_cast_code :type_cast_code
      alias :old_simplified_type :simplified_type
      alias :old_klass :klass
      def type_cast_code(var_name)
        type == :hstore ? "#{var_name}.from_hstore" : old_type_cast_code(var_name)
      end
      def simplified_type(field_type)
        field_type =~ /^hstore$/ ? :hstore : old_simplified_type(field_type)
      end
      def klass
        type == :hstore ? Hstore : old_klass   
      end
    end
    class PostgreSQLAdapter < AbstractAdapter
      alias :old_quote :quote
      def quote(value, column = nil)
        if value.kind_of?(NilClass)
          return "default"
        elsif column && column.sql_type =~ /^hstore$/
          raise HstoreTypeMismatch, "#{column.name} must have a Hash value" unless value.kind_of?(Hash)
          return value.to_hstore
        end
        old_quote(value,column)
      end
    end
  end
end
