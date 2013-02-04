#!/bin/sh

VERSION="0.1"
PROGNAME=`basename $0`

PUSHOVER_TOKEN=""
PUSHOVER_USER=""
PUSHOVER_MESSAGE=""
PUSHOVER_DEVICE=""
PUSHOVER_TITLE=""
PUSHOVER_URL=""
PUSHOVER_URL_TITLE=""
PUSHOVER_PRIORITY=""
PUSHOVER_TIMESTAMP=""
PUSHOVER_SOUND=""

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
    curl -s \
        -F "token=$PUSHOVER_TOKEN" \
        -F "user=$PUSHOVER_USER" \
        -F "message=$PUSHOVER_MESSAGE" \
        -F "device=$PUSHOVER_DEVICE" \
        -F "title=$PUSHOVER_TITLE" \
        -F "url=$PUSHOVER_URL" \
        -F "url_title=$PUSHOVER_URL_TITLE" \
        -F "priority=$PUSHOVER_PRIORITY" \
        -F "timestamp=$PUSHOVER_TIMESTAMP" \
        -F "sound=$PUSHOVER_SOUND" \
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
            PUSHOVER_USER=$OPTARG
            ;;
        a)
            PUSHOVER_TOKEN=$OPTARG
            ;;
        m)
            PUSHOVER_MESSAGE=$OPTARG
            ;;
        d)
            PUSHOVER_DEVICE=$OPTARG
            ;;
        q)
            PUSHOVER_TITLE=$OPTARG
            ;;
        w)
            PUSHOVER_URL=$OPTARG
            ;;
        e)
            PUSHOVER_URL_TITLE=$OPTARG
            ;;
        p)
            PUSHOVER_PRIORITY=$OPTARG
            ;;
        t)
            PUSHOVER_TIMESTAMP=$OPTARG
            ;;
        s)
            PUSHOVER_sound=$OPTARG
            ;;
        \?)
            # getopts issues an error message
            print_version >&2
            print_usage >&2
            ;;
    esac
done

shift `expr $OPTIND - 1`

if [ "$PUSHOVER_MESSAGE" = "" ]
then
    PUSHOVER_MESSAGE="$*"
fi

if [ "$PUSHOVER_USER" = "" ] || [ "$PUSHOVER_TOKEN" = "" ] || [ "$PUSHOVER_MESSAGE" = "" ]
then
    print_version >&2
    print_usage >&2
    exit 1
fi

RETVAL=`push_message`
if [ "$RETVAL" = *errors* ]
then
    ERROR=`echo $RETVAL | sed 's/.*errors\":\[\(".*"\)\].*/\1/'`
    echo "error: $ERROR" >&2
    exit 1
fi

# EOF
