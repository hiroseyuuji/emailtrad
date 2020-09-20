#!/usr/bin/env ruby
require 'time'

while line=gets
  break if /^$/ =~ line
  tm = nil
  if /^Date: (.*0000)/ =~ line
    begin
      tm = Time.parse($1)
    rescue
      print line
      next
    end
    printf("Date: %s\n", tm.localtime.rfc822)
  else
    print line
  end
end
puts
print ARGF.readlines.join
