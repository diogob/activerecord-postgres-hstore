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
  end


  module ConnectionAdapters
    #I believe this change will break the ability to do a schema dump as per issue #83
    #https://github.com/engageis/activerecord-postgres-hstore/commit/ca34391c776949c13d561870067ddf581f0561b9#lib/activerecord-postgres-hstore/activerecord.rb
    if(RUBY_PLATFORM != 'java')
      class PostgreSQLColumn < Column
        # Adds the hstore type for the column.
        def simplified_type_with_hstore(field_type)
          field_type == 'hstore' ? :hstore : simplified_type_without_hstore(field_type)
        end

        alias_method_chain :simplified_type, :hstore
      end

      class PostgreSQLAdapter < AbstractAdapter
        def native_database_types_with_hstore
          native_database_types_without_hstore.merge({:hstore => { :name => "hstore" }})
        end

        alias_method_chain :native_database_types, :hstore
      end
    else
      class PostgreSQLColumn
        # Adds the hstore type for the column.
        def simplified_type_with_hstore(field_type)
          field_type == 'hstore' ? :hstore : simplified_type_without_hstore(field_type)
        end

        alias_method_chain :simplified_type, :hstore
      end

      class PostgreSQLAdapter
        def native_database_types_with_hstore
          native_database_types_without_hstore.merge({:hstore => { :name => "hstore" }})
        end

        alias_method_chain :native_database_types, :hstore
      end
    end

    module SchemaStatements

      # Installs hstore by creating the Postgres extension
      # if it does not exist
      #
      def install_hstore
        execute "CREATE EXTENSION IF NOT EXISTS hstore"
      end

      # Uninstalls hstore by dropping Postgres extension if it exists
      #
      def uninstall_hstore
        execute "DROP EXTENSION IF EXISTS hstore"
      end

      # Adds a GiST or GIN index to a table which has an hstore column.
      #
      # Example:
      #   add_hstore_index :people, :info, :type => :gin
      #
      # Options:
      #   :type  = :gist (default) or :gin
      #
      # See http://www.postgresql.org/docs/9.2/static/textsearch-indexes.html for more information.
      #
      def add_hstore_index(table_name, column_name, options = {})
        index_name, index_type, index_columns = add_index_options(table_name, column_name, options)
        index_type = index_type.present? ? index_type : 'gist'
        execute "CREATE INDEX #{index_name} ON #{table_name} USING #{index_type}(#{column_name})"
      end

      # Removes a GiST or GIN index of a table which has an hstore column.
      #
      # Example:
      #   remove_hstore_index :people, :info
      #
      def remove_hstore_index(table_name, options = {})
        index_name = index_name_for_remove(table_name, options)
        execute "DROP INDEX #{index_name}"
      end

    end

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
  end
end
