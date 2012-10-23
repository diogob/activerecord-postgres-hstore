class Hash
  HSTORE_ESCAPED = /[,\s=>\\]/

  # Escapes values such that they will work in an hstore string
  def hstore_escape(str)
    if str.nil?
      return 'NULL'
    end

    str = str.to_s.dup
    # backslash is an escape character for strings, and an escape character for gsub, so you need 6 backslashes to get 2 in the output.
    # see http://stackoverflow.com/questions/1542214/weird-backslash-substitution-in-ruby for the gory details
    str.gsub!(/\\/, '\\\\\\')
    # escape backslashes before injecting more backslashes
    str.gsub!(/"/, '\"')

    if str =~ HSTORE_ESCAPED or str.empty?
      str = '"%s"' % str
    end

    return str
  end

  # Generates an hstore string format. This is the format used
  # to insert or update stuff in the database.
  def to_hstore
    return "" if empty?

    map do |idx, val|
      "%s=>%s" % [hstore_escape(idx), hstore_escape(val)]
    end * ","
  end

  # If the method from_hstore is called in a Hash, it just returns self.
  def from_hstore
    ActiveSupport::HashWithIndifferentAccess.new(self)
  end

end
