# emailtrad
Filters for traditional MUA and command line lovers
## Split off rich HTML part
Put this combination into your ~/.forward or ~/.qmail
```
| textplain.rb
```
## Prefer localtime in Date: header
Some MUAs like Rainloop add GMT date header that cannot be
problem on most MUA, but causes inconvenience to GMT unaware MUA.
If you prefer localtime header, put this into your .forward/.qail file.
```
| datelocal.rb
```
## Sending multiple binary files to multiple recipients
Use sendmultipart.sh like this:
```
% cat Message.txt | sendmultipart.sh -t RCPT1,RCPT2,RCPT3,... -s Subject
```
See further note in sendmultipart.sh itself.
