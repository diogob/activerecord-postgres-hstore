class ActiveRecord::ConnectionAdapters::TableDefinition
  %w( hstore ).each do |column_type|
    class_eval <<-EOV, __FILE__, __LINE__ + 1
      def #{column_type}(*args)                                               # def hstore(*args)
        options = args.extract_options!                                       #   options = args.extract_options!
        column_names = args                                                   #   column_names = args
                                                                              #
        column_names.each { |name| column(name, '#{column_type}', options) }  #   column_names.each { |name| column(name, 'hstore', options) }
      end                                                                     # end
    EOV
  end
end
