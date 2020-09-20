#!/usr/bin/env ruby
# coding: binary
# Extract message body from RFC5322 stream as text/plain charset=iso-2022-jp.
# (C)2015 by HIROSE Yuuji [yuuji<at>gentei.org]
# Last modified Sun Sep 20 10:50:25 2020 on firestorm
require 'nkf'
require 'kconv'
require 'base64'

body=readlines.join

def catTextPlainHeader(body)
  header=body.split(/^$/)[0]
#  header.gsub!(/^(Content-(type|transfer-encoding): .*)(\n\s+)(\S+)/mi,
#              '\1'+' \4')
  header.gsub!(/^(Content-(type|transfer-encoding): [^\n]*?\n)(\s+?[^\n]+\n)*/mi, '')
  # print NKF::nkf('-jM', header)
  print header
  print "Content-type: text/plain; charset=iso-2022-jp\n"
  print "X-Filtered: $HGid: textplain.rb,v 1031:f89b6f857afa 2020-09-20 10:51 +0859 yuuji $\n\n"
end
def catbody(body)
  header=body.split(/^$/)[0]
  rest=body.sub(/.*?^$/m, "").sub("\n", "")
  #print header

  if /^content-type:/i !~ header
    # no MIME
    print rest.tojis
    return true
  elsif %r,^content-type: text/plain,i =~ header
    ic = if %r,^content-type: text/plain.*charset=([\"\']?)(.*)\1,i =~ header
           " --ic="+$2
         else
           ""
         end
    if %r,^content-transfer-encoding:\s+(.*),mi =~ header
      case $1
      when /bit/i
        print rest.tojis
      when /base64/i
        print NKF.nkf("-dj#{ic}", Base64.decode64(rest))	# strip '\r'
      when /quoted-printable/i
        print NKF::nkf("-jmQ#{ic}", rest)
      end
      return true
    else
      print rest
      return true
    end
  elsif %r,content-type: multipart,i =~ header
    if /boundary=(['"]?)(.*)\1/ =~ header
      boundary = $2
      #puts rest.split("--"+boundary)[1..-1].length
      rest.split("--"+boundary+"\n")[1..-1].each do |part|
        # printf("part=[[%s]]\n", part)
        catbody(part) and return true
      end
    end
  end
end
/mailbody/ =~ File.basename($0) or catTextPlainHeader(body)
catbody(body)
