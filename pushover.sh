#!/bin/sh

VERSION="0.1"
PROGNAME="$(basename $0)"

CONFIG="$HOME/.pushover"

PUSHOVER_USER_TOKEN=""
PUSHOVER_API_TOKEN=""
PUSHOVER_TARGET_DEVICE=""
PUSHOVER_MESSAGE_TEXT=""
PUSHOVER_MESSAGE_TITLE=""
PUSHOVER_MESSAGE_URL=""
PUSHOVER_MESSAGE_URL_TITLE=""
PUSHOVER_MESSAGE_PRIORITY=""
PUSHOVER_MESSAGE_TIMESTAMP=""
PUSHOVER_NOTIFICATION_SOUND=""

if [ -f "$CONFIG" ]
then
    . "$CONFIG"
fi

print_usage () {
    cat <<EOT
Usage:	$PROGNAME -u <user key> -a <api key> [<options>] message

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
EOT
}

print_version () {
    echo "$PROGNAME $VERSION"
}

push_message () {
    curl -ks \
        -F "token=$PUSHOVER_API_TOKEN" \
        -F "user=$PUSHOVER_USER_TOKEN" \
        -F "message=$PUSHOVER_MESSAGE_TEXT" \
        -F "device=$PUSHOVER_TARGET_DEVICE" \
        -F "title=$PUSHOVER_MESSAGE_TITLE" \
        -F "url=$PUSHOVER_MESSAGE_URL" \
        -F "url_title=$PUSHOVER_MESSAGE_URL_TITLE" \
        -F "priority=$PUSHOVER_MESSAGE_PRIORITY" \
        -F "timestamp=$PUSHOVER_MESSAGE_TIMESTAMP" \
        -F "sound=$PUSHOVER_NOTIFICATION_SOUND" \
        https://api.pushover.net/1/messages.json
}

while getopts hvu:a:m:d:q:w:e:p:t:s: OPT; do
    case "$OPT" in
        h)
            print_version
            print_usage
            exit 0
            ;;
        v)
            print_version
            exit 0
            ;;
        u)
            PUSHOVER_USER_TOKEN=$OPTARG
            ;;
        a)
            PUSHOVER_API_TOKEN=$OPTARG
            ;;
        m)
            PUSHOVER_MESSAGE_TEXT=$OPTARG
            ;;
        d)
            PUSHOVER_TARGET_DEVICE=$OPTARG
            ;;
        q)
            PUSHOVER_MESSAGE_TITLE=$OPTARG
            ;;
        w)
            PUSHOVER_MESSAGE_URL=$OPTARG
            ;;
        e)
            PUSHOVER_MESSAGE_URL_TITLE=$OPTARG
            ;;
        p)
            PUSHOVER_MESSAGE_PRIORITY=$OPTARG
            ;;
        t)
            PUSHOVER_MESSAGE_TIMESTAMP=$OPTARG
            ;;
        s)
            PUSHOVER_NOTIFICATION_SOUND=$OPTARG
            ;;
        \?)
            # getopts issues an error message
            print_version >&2
            print_usage >&2
            ;;
    esac
done

shift "$(expr $OPTIND - 1)"

if [ "$PUSHOVER_MESSAGE_TEXT" = "" ]
then
    PUSHOVER_MESSAGE_TEXT="$*"
fi

if [ "$PUSHOVER_USER_TOKEN" = "" ] || [ "$PUSHOVER_API_TOKEN" = "" ] || [ "$PUSHOVER_MESSAGE_TEXT" = "" ]
then
    print_version >&2
    print_usage >&2
    exit 1
fi

RETVAL="$(push_message)"
if (echo "$RETVAL" | grep "error" > /dev/null)
then
    ERROR="$(echo $RETVAL | sed 's/.*errors\":\[\(".*"\)\].*/\1/')"
    echo "error: $ERROR" >&2
    exit 1
fi

# EOF
