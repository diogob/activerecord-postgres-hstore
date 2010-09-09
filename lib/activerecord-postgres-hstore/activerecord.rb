# ActiveRecord::ConnectionAdapters::PostgreSQLColumn.new('data','','hstore').type
module ActiveRecord
  class Base
    def self.delete_key attribute, key
      #UPDATE tab SET h = delete(h, 'k1');
      unless column_names.include?(attribute.to_s)
        raise "invalid attribute #{attribute}"
      end
      update_all(["#{attribute} = delete(#{attribute},?)",key])
    end
    def self.delete_keys attribute, *keys
      unless column_names.include?(attribute.to_s)
        raise "invalid attribute #{attribute}"
      end
      delete_str = "delete(#{attribute},?)"
      (keys.count-1).times do
        delete_str = "delete(#{delete_str},?)"
      end
      update_all(["#{attribute} = #{delete_str}", *keys])
    end
    
    def destroy_key attribute, key
      unless self.class.column_names.include?(attribute.to_s)
        raise "invalid attribute #{attribute}"
      end
      new_value = send(attribute)
      new_value.delete(key.to_s)
      send("#{attribute}=", new_value)
      self
    end
    def destroy_key! attribute, key
      destroy_key(attribute, key).save
    end
    def destroy_keys attribute, *keys
      for key in keys
        new_value = send(attribute)
        new_value.delete(key.to_s)
        send("#{attribute}=", new_value)
      end
      self
    end
    def destroy_keys! attribute, *keys
      unless self.class.column_names.include?(attribute.to_s)
        raise "invalid attribute #{attribute}"
      end
      destroy_keys(attribute, *keys).save
    end

    # For Rails 3 compat :D
    #alias :old_arel_attributes_values :arel_attributes_values
    def arel_attributes_values(include_primary_key = true, include_readonly_attributes = true, attribute_names = @attributes.keys)
      attrs = {}
      attribute_names.each do |name|
        if (column = column_for_attribute(name)) && (include_primary_key || !column.primary)

          if include_readonly_attributes || (!include_readonly_attributes && !self.class.readonly_attributes.include?(name))
            value = read_attribute(name)

            if value && ((self.class.serialized_attributes.has_key?(name) && (value.acts_like?(:date) || value.acts_like?(:time))) || value.is_a?(Hash) || value.is_a?(Array))
              if self.class.columns_hash[name].type == :hstore
                value = value.to_hstore # Done!
              else
                value = value.to_yaml
              end
            end
            attrs[self.class.arel_table[name]] = value
          end
        end
      end
      attrs
    end
  end
  class HstoreTypeMismatch < ActiveRecord::ActiveRecordError
  end
  module ConnectionAdapters
  
    class TableDefinition
      # Adds hstore type for migrations
      def hstore(*args)
        options = args.extract_options!
        column_names = args
        column_names.each { |name| column(name, 'hstore', options) }
      end
    end

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
        if value && column && column.sql_type =~ /^hstore$/
          if ! value.kind_of?(Hash) and ! value.valid_hstore?
            raise HstoreTypeMismatch, "#{column.name} must have a Hash or a valid hstore value (#{value})"
          end
          return value.to_hstore
        end
        old_quote(value,column)
      end
    end
  end
end
