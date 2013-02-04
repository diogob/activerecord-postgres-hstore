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
        obj.nil? ? (@default.nil? ? nil : to_hstore(@default)) : to_hstore(obj)
      end

      def load(hstore)
        hstore.nil? ? @default : from_hstore(hstore)
      end

      private
      # Escapes values such that they will work in an hstore string
      def hstore_escape(str)
        return 'NULL' if str.nil?
        return str if str =~ /^".*"$/
        '"%s"' % str
      end

      def to_hstore obj
        return "" if obj.empty?
        obj.map do |idx, val| 
          "%s=>%s" % [hstore_escape(idx), hstore_escape(val)]
        end * ","
      end

      def hstore_pair
        quoted_string = /"[^"\\]*(?:\\.[^"\\]*)*"/
        unquoted_string = /[^\s=,][^\s=,\\]*(?:\\.[^\s=,\\]*|=[^,>])*/
        string = /(#{quoted_string}|#{unquoted_string})/
        /#{string}\s*=>\s*#{string}/
      end

      def from_hstore hstore
        token_pairs = (hstore.scan(hstore_pair)).map { |k,v| [k,v =~ /^NULL$/i ? nil : v] }
        token_pairs = token_pairs.map { |k,v|
          [k,v].map { |t| 
            case t
            when nil then t
            when /\A"(.*)"\Z/m then $1.gsub(/\\(.)/, '\1')
            else t.gsub(/\\(.)/, '\1')
            end
          }
        }
        Hash[ token_pairs ]
      end
    end
  end
end

