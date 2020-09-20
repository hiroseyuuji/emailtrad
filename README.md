# emailtrad
Filters for traditional MUA and command line lovers
## Split off rich HTML part
*Assuming you using postfix/qmail email extensional address*

Put this combination into your ~/.forward or ~/.qmail
```
# Postfix recipient_delimiter = +
| textplain.rb | sendmail you+genuine
# qmail
| textplain.rb | qmail-inject you-genuine
```
Create genuine maildir container as ~/.forward+*genuine* or ~/.qmail-*genuine*
```
# Postfix
/home/you/maildir/
# qmail
./maildir/
```
It extracts text part of message and convert them to iso-2022-jp,
traditional encoding system in Japan.
## Prefer localtime in Date: header
Some MUAs like Rainloop add GMT date header that cannot be
problem on most MUA, but causes inconvenience to GMT unaware MUA.
If you prefer localtime header, put this into your .forward/.qail file.
```
| datelocal.rb | sendmail you+genuine
```
## Sending multiple binary files to multiple recipients
Use sendmultipart.sh like this:
```
% cat Message.txt | sendmultipart.sh -t RCPT1,RCPT2,RCPT3,... -s Subject
```
See further note in sendmultipart.sh itself.
