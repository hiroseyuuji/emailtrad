#!/bin/sh
# Send Mime-1.0 messages with iso-2022-jp encoding
myname=`basename $0`
usage() {
  cat<<-EOF
	Usage: cat MessageBody | $myname -s SUBJECT Recipients...
	Options:
	  -n	No send, dry run.
	Example:
	cat *.csv | while IFS=, read email name rest; do
	  nkf -e body.txt | m4 -D__NAME__="\$name" \\
	  | MAILHOST=example.com $myname -s "A Hoge hoge message" \$email
	done
	EOF
  exit 0
}
test -z "$1" && usage

sendmail="sendmail -t"
while getopts ns: i; do
  case "$i" in
    s)	sj=`echo "$OPTARG" | nkf -jM` ;;
    n)	sendmail=cat ;;
    *)	usage ;;
  esac
done
shift $((OPTIND - 1))
test -z "$sj" && usage
test -z "$1" && usage

body=`nkf -j`
for rcp in "$@"; do
  $sendmail <<-EOF
	To: $rcp
	Subject: $sj
	Content-type: text/plain; charset=iso-2022-jp
	Mime-version: 1.0

	$body
	EOF
done
