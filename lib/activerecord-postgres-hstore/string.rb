class String

  def to_hstore
    self
  end

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

  def from_hstore
    Hash[ scan(/"([^"]+)"=>"([^"]+)"/) ]
  end

end
