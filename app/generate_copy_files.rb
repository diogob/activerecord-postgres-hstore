Foo;Bar
foos = File.open('foos.copy','w')
bars = File.open('bars.copy','w')
copy_info = <<-COPY_INFO
COPY tablename [ ( column [, ...] ) ]
    FROM { 'filename' | STDIN }
    [ [ WITH ] 
          [ BINARY ] 
          [ OIDS ]
          [ DELIMITER [ AS ] 'delimiter' ]
          [ NULL [ AS ] 'null string' ]
          [ CSV [ QUOTE [ AS ] 'quote' ] 
                [ ESCAPE [ AS ] 'escape' ]
                [ FORCE NOT NULL column [, ...] ]

COPY tablename [ ( column [, ...] ) ]
    TO { 'filename' | STDOUT }
    [ [ WITH ] 
          [ BINARY ]
          [ OIDS ]
          [ DELIMITER [ AS ] 'delimiter' ]
          [ NULL [ AS ] 'null string' ]
          [ CSV [ QUOTE [ AS ] 'quote' ] 
                [ ESCAPE [ AS ] 'escape' ]
                [ FORCE QUOTE column [, ...] ]
COPY_INFO

1000000.times do |i|
  h = {
    'copy' => copy_info,
    'first key' => i,
    'another key' => i*10,
    'last key' => i*1000,
    'foo' => 'bar'
  }
  if i % 10000 == 0
    perc = i/10000
    puts "#{perc}%"
  end
  foos.write(h.to_yaml.gsub("\n",'\n')+"\n")
  bars.write(h.map{|k,v| %("#{k}"=>"#{v}")}.join(" ,").gsub("\n",'\n')+"\n")
end
foos.close
bars.close
`chmod 0777 bars.copy`
`chmod 0777 foos.copy`

