module ActiveRecord
  module Coders
    class Hstore
      def self.load(hstore)
        new.load(hstore)
      end

      def self.dump(hstore)
        new.dump(hstore)
      end

      def initialize(default=nil)
        @default=default
      end

      def dump(obj)
        obj.nil? ? (@default.nil? ? nil : @default.to_hstore) : obj.to_hstore
      end

      def load(hstore)
        hstore.nil? ? nil : hstore.from_hstore
      end
    end
  end
end

