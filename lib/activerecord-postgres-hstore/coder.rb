require 'pg_hstore'

module ActiveRecord
  module Coders
    class Hstore
      def self.load(hstore)
        new({}).load(hstore)
      end

      def self.dump(hstore)
        new({}).dump(hstore)
      end

      def initialize(default=nil)
        @default=default
      end

      def dump(obj)
        obj.nil? ? (@default.nil? ? nil : to_hstore(@default)) : to_hstore(obj)
      end

      def load(hstore)
        hstore.nil? ? @default : from_hstore(hstore)
      end

      private

      def to_hstore obj
        PgHstore.dump obj, true
      end

      def from_hstore hstore
        PgHstore.load hstore, false
      end
    end
  end
end

