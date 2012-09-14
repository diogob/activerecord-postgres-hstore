# Extends AR to add Hstore functionality.
module ActiveRecord

  # Adds methods for deleting keys in your hstore columns
  class Base

    # Deletes all keys from a specific column in a model. E.g.
    #   Person.delete_key(:info, :father)
    # The SQL generated will be:
    #   UPDATE "people" SET "info" = delete("info",'father');
    def self.delete_key attribute, key
      raise "invalid attribute #{attribute}" unless column_names.include?(attribute.to_s)
      update_all([%(#{attribute} = delete("#{attribute}",?)),key])
    end

    # Deletes many keys from a specific column in a model. E.g.
    #   Person.delete_key(:info, :father, :mother)
    # The SQL generated will be:
    #   UPDATE "people" SET "info" = delete(delete("info",'father'),'mother');
    def self.delete_keys attribute, *keys
      raise "invalid attribute #{attribute}" unless column_names.include?(attribute.to_s)
      delete_str = "delete(#{attribute},?)"
      (keys.count-1).times{ delete_str = "delete(#{delete_str},?)" }
      update_all(["#{attribute} = #{delete_str}", *keys])
    end

    # Deletes a key in a record. E.g.
    #   witt = Person.find_by_name("Ludwig Wittgenstein")
    #   witt.destroy_key(:info, :father)
    # It does not save the record, so you'll have to do it.
    def destroy_key attribute, key
      raise "invalid attribute #{attribute}" unless self.class.column_names.include?(attribute.to_s)
      new_value = send(attribute)
      new_value.delete(key.to_s)
      send("#{attribute}=", new_value)
      self
    end

    # Deletes a key in a record. E.g.
    #   witt = Person.find_by_name("Ludwig Wittgenstein")
    #   witt.destroy_key(:info, :father)
    # It does save the record.
    def destroy_key! attribute, key
      destroy_key(attribute, key).save
    end

    # Deletes many keys in a record. E.g.
    #   witt = Person.find_by_name("Ludwig Wittgenstein")
    #   witt.destroy_keys(:info, :father, :mother)
    # It does not save the record, so you'll have to do it.
    def destroy_keys attribute, *keys
      for key in keys
        new_value = send(attribute)
        new_value.delete(key.to_s)
        send("#{attribute}=", new_value)
      end
      self
    end

    # Deletes many keys in a record. E.g.
    #   witt = Person.find_by_name("Ludwig Wittgenstein")
    #   witt.destroy_keys!(:info, :father, :mother)
    # It does save the record.
    def destroy_keys! attribute, *keys
      raise "invalid attribute #{attribute}" unless self.class.column_names.include?(attribute.to_s)
      destroy_keys(attribute, *keys).save
    end

    if defined?(Rails) && Rails.version < '3.1.0'
    # This method is replaced for Rails 3 compatibility.
    # All I do is add the condition when the field is a hash that converts the value
    # to hstore format.
    # IMHO this should be delegated to the column, so it won't be necessary to rewrite all
    # this method.
    def arel_attributes_values(include_primary_key = true, include_readonly_attributes = true, attribute_names = @attributes.keys)
      attrs = {}
      attribute_names.each do |name|
        if (column = column_for_attribute(name)) && (include_primary_key || !column.primary)
          if include_readonly_attributes || (!include_readonly_attributes && !self.class.readonly_attributes.include?(name))
            value = read_attribute(name)
            if self.class.columns_hash[name].type == :hstore && value && value.is_a?(Hash)
              value = value.to_hstore # Done!
            elsif value && self.class.serialized_attributes.has_key?(name) && (value.acts_like?(:date) || value.acts_like?(:time) || value.is_a?(Hash) || value.is_a?(Array))
              value = value.to_yaml
            end
            attrs[self.class.arel_table[name]] = value
          end
        end
      end
      attrs
    end
    end

  end

  # This erro class is used when the user passes a wrong value to a hstore column.
  # Hstore columns accepts hashes or hstore valid strings. It is validated with
  # String#valid_hstore? method.
  class HstoreTypeMismatch < ActiveRecord::ActiveRecordError
  end

  module ConnectionAdapters

    class TableDefinition

      # Adds hstore type for migrations. So you can add columns to a table like:
      #   create_table :people do |t|
      #     ...
      #     t.hstore :info
      #     ...
      #   end
      def hstore(*args)
        options = args.extract_options!
        column_names = args
        column_names.each { |name| column(name, 'hstore', options) }
      end

    end

    class Table

      # Adds hstore type for migrations. So you can add columns to a table like:
      #   change_table :people do |t|
      #     ...
      #     t.hstore :info
      #     ...
      #   end
      def hstore(*args)
        options = args.extract_options!
        column_names = args
        column_names.each { |name| column(name, 'hstore', options) }
      end

    end

    class PostgreSQLColumn < Column
      # Does the type casting from hstore columns using String#from_hstore or Hash#from_hstore.
      def type_cast_code_with_hstore(var_name)
        type == :hstore ? "#{var_name}.from_hstore" : type_cast_code_without_hstore(var_name)
      end

      # Adds the hstore type for the column.
      def simplified_type_with_hstore(field_type)
        field_type == 'hstore' ? :hstore : simplified_type_without_hstore(field_type)
      end

      alias_method_chain :type_cast_code, :hstore
      alias_method_chain :simplified_type, :hstore
    end

    class PostgreSQLAdapter < AbstractAdapter
      def native_database_types_with_hstore
        native_database_types_without_hstore.merge({:hstore => { :name => "hstore" }})
      end

      # Quotes correctly a hstore column value.
      def quote_with_hstore(value, column = nil)
        if value && column && column.sql_type == 'hstore'
          raise HstoreTypeMismatch, "#{column.name} must have a Hash or a valid hstore value (#{value})" unless value.kind_of?(Hash) || value.valid_hstore?
          return quote_without_hstore(value.to_hstore, column)
        end
        quote_without_hstore(value,column)
      end

      alias_method_chain :quote, :hstore
      alias_method_chain :native_database_types, :hstore
    end
  end
end
