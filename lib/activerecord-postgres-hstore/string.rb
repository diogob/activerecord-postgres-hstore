class String

  # If the value os a column is already a String and it calls to_hstore, it
  # just returns self. Validation occurs afterwards.
  def to_hstore
    self
  end

  # Validates the hstore format. Valid formats are:
  # * An empty string
  # * A string like %("foo"=>"bar"). I'll call it a "double quoted hstore format".
  # * A string like %('foo'=>'bar'). I'll call it a "single quoted hstore format".
  def valid_hstore?
    return true if empty? || self == "''"
    # This is what comes from the database
    dbl_quotes_re = /"([^"]+)"=>"([^"]+)"/
    # TODO
    # This is what comes from the plugin
    # this is a big problem, 'cause regexes does not know how to count...
    # how should i very values quoted with two single quotes? using .+ sux.
    sngl_quotes_re = /'(.+)'=>'(.+)'/
    self.match(dbl_quotes_re) || self.match(sngl_quotes_re)
  end

  # Creates a hash from a valid double quoted hstore format, 'cause this is the format
  # that postgresql spits out.
  def from_hstore
    Hash[ scan(/"([^"]+)"=>"([^"]+)"/) ]
  end

  def escape_quotes
    self.gsub(/'/,"''")
  end

end
