#!/bin/sh
# 愛
# send multipart message via email
# (C)2012,2015,2020 by HIROSE Yuuji [yuuji(at)yatex.org]
# You can obtain the latest version of this script from:
#   http://www.gentei.org/~yuuji/software/sendmultipart.sh
# Last modified Tue Jun 16 15:05:18 2020 on firestorm
#
# Typical usage:
#  echo "Hi, here's photo I've taken.  Enjoy" | \
#    sendmultipart.sh -t rcpt1@example.com,rcpt2@example.org \
#      -s "Photo of party" -f myself@example.net photo*.jpg

myname=`basename $0`
usage () {
  cat<<_EOU_
$myname: Send multipart message via email
Usage: $0 -t recipient [options] file(s)
	-t ToAddress	Recipient address.
			Multiple -t option and/or Multiple ToAddresses
			delimited by comma are acceptable.
	-c CarbonCopy	Recipient address of Cc:
	-s Subject	Set subject to \`Subject'
	-f FromAddress	Set From: header to \`FromAddress'
	-r ReplyTo	Set Reply-to: header to \`ReplyTo'
_EOU_
  exit 0
}

conf=~/.sendmultipart
verbose=0
hgid='$HGid: sendmultipart.sh,v 1026:6fbab3c79e5b 2020-06-16 15:07 +0900 yuuji $'
mailer=`echo $hgid|cut -d' ' -f2,3,4`

base64byuu() {
  uuencode -m $1 < $1 | tail +2
}
base64=${BASE64:-base64byuu}
boundary="${mailer}_`date +%Y%m%d,%H%M%Sx`"
ctheader="Content-Type: Multipart/Mixed;
 boundary=\"$boundary\""
textcharset=iso-2022-jp
rcpts=""
nl="
"
rcptheader=""

[ -f $conf ] && . $conf		# read rc file

while [ x"$1" != x"" ]; do
  case "$1" in
    -t)	shift; rcpts="$rcpts${rcpts:+ }`echo $1|tr , ' '`" ;;
    -c)	shift; ccs="$ccs${ccs:+ }`echo $1|tr , ' '`" ;;
    -s) shift; subject="`echo $1|nkf -M`" ;;
    -r) shift; REPLYTO="$1" ;;
    -f) shift; from="From: $1" ;;
    -v)	verbose=1 ;;
    -h) usage ;;		# -h helpオプション
    --) shift; break ;;
    *)	break ;;		# -で始まらないものが来たら即処理突入
  esac
  shift	
done
rcptheader=${SMAIL_TO:-`echo $rcpts|tr ' ' '\n'|sort -u|tr '\n' ,\
	| sed 's/,$//;s/,/, /g'`}
if [ -n "$ccs" ]; then
  ccheader=${SMAIL_CC:-`echo -n $ccs|tr ' ' '\n'|sort -u|tr '\n' ,`}
  CC="${nl}Cc: `echo $ccheader|sed 's/,$//;s/,/, /g'`"
fi
plainheader="Content-Type: text/plain; charset=$textcharset
Content-Transfer-Encoding: 7bit"

tolower() {
  tr '[A-Z]' '[a-z]'
}
cattextwithheader() {
  coding=`nkf -g $1|cut -d' ' -f1`
  case `echo $coding | tolower` in
    iso-2022-jp) encoding=7bit   cat=cat;;
    *)		 encoding=base64 cat="$base64" ;;
  esac
  filename=`echo $1|nkf -M`
  cat<<EOF
Content-Type: text/plain; charset=$coding
Content-Disposition: inline; filename="$filename"
Content-Transfer-Encoding: $encoding

EOF
  $cat $1
}

# Begin procedure
if [ x"$rcpts" = x"" ]; then
  sendmail="cat"
else
  sendmail="sendmail"
fi
body=`nkf -dj`			# Convert stdin to iso-2022-jp

# Generate contents
( cat<<EOF
To: ${rcptheader:-[Not specified]}$CC
${REPLYTO:+Reply-to: $REPLYTO$nl}Subject: ${subject:-$*}
$ctheader
Mime-Version: 1.0
X-Mailer: $mailer
$from

--$boundary
$plainheader

EOF
  echo "$body"
  echo
  for file in "$@"; do
    echo "--$boundary"
    ct=`file --mime-type - < "$file" | cut -d' ' -f2`
    case "$ct" in
      [Tt]ext/[Pp]lain*)
	cattextwithheader "$file"
	;;
      *)
	echo "Content-Type: $ct"
	fn=${file##*/}
	echo "Content-Transfer-Encoding: base64"
	echo "Content-Disposition: inline; filename=\"$fn\""
	echo
	$base64 $file
	;;
    esac
    echo
  done
  echo "--${boundary}--"
) | $sendmail $rcpts $ccs

exit 0
