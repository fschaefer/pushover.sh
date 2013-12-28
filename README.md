Pushover: Simple Mobile Notifications for Android and iOS (https://pushover.net/)

pushover.sh
===========

Shell script to push messages to Android and iOS devices via Pushover

Usage:
```
pushover.sh 0.1
Usage:	pushover.sh -u <user key> -a <api key> [<options>] message

Supported options:
    -h              print this help message
    -v              print version
    -u  <user key>  user key (not e-mail address)
    -a  <api key>   application's API token
    -m  <message>   the message to send
    -d  <device>    device identifier to send the message directly to
    -q  <title>     message's title, otherwise uses the app's name
    -w  <url>       a supplementary URL to show with the message
    -e  <url title> a title for the supplementary URL
    -p  <priority>  set to "1" to display as high-priority and bypass quiet hours,
                    or "-1" to always send as a quiet notification
    -t  <timestamp> a Unix timestamp to show message the with a particular time
    -s  <sound>     name of one of the sounds supported by device clients to override
                    the user's default sound choice
```
