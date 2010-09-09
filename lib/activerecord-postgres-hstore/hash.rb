class Hash

  def to_hstore
    return "''" if empty?
    #@todo DIOGO! Check security issues with this quoting pleaz
    map{|idx,val| "('#{idx}'=>'#{val.to_s.gsub(/'/,"''")}')"  }.join(' || ')
  end

  def from_hstore
    self
  end

end
