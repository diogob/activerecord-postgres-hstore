class Hash

  # Generates a single quoted hstore string format. This is the format used
  # to insert or update stuff in the database.
  def to_hstore
    return "''" if empty?
    #@todo DIOGO! Check security issues with this quoting pleaz
    map{|idx, val| "('#{idx.to_s.escape_quotes}'=>'#{val.to_s.escape_quotes}')"  }.join(' || ')
  end

  # If the method from_hstore is called in a Hash, it just returns self.
  def from_hstore
    self
  end

end
