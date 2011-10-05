class Hash

  # Generates a single quoted hstore string format. This is the format used
  # to insert or update stuff in the database.  The formats differ
  # based on the version of AR because of the point at which
  # (type_cast vs quote) this string is being generated, and thus
  # how it is passed to PG.
  if ActiveRecord::VERSION::MAJOR >= 3 && ActiveRecord::VERSION::MINOR >= 1

    def to_hstore
      return "" if empty?
      map {|idx, val| %Q{"#{idx.to_s}"=>"#{val.to_s}"}  }.join(', ')
    end

  else

    def to_hstore
      return "''" if empty?
      map {|idx, val| "('#{idx.to_s.escape_quotes}'=>'#{val.to_s.escape_quotes}')"  }.join(' || ')
    end

  end
  
  # If the method from_hstore is called in a Hash, it just returns self.
  def from_hstore
    self
  end

end
