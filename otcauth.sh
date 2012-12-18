#!/bin/bash

# install in ~/.kde/share/apps/konversation/scripts as otcauth
# chmod +x that file
# enable logging such that gribble from freenode ends up in
# ~/.kde/share/apps/konversation/logs/freenode_gribble.log
# restart konversation
# and then enjoy automatic auth script
# by going /otcauth NICKNAME
# directly from konversation

set -e

unset CDPATH
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
tty -s || exec konsole -e bash "$DIR"/`basename "$0"` "$@"

NICK=Rudd-O
test -z "$1" || NICK="$1"

function error() {
  echo "The script cannot find or resolve the one time pad"
  sleep 5
  exit "${CODE}"
}
trap error ERR

qdbus org.kde.konversation /irc say Freenode gribble "gpg eauth $NICK"
echo "Waiting for reply from bot..." >> /dev/stderr
sleep 3
urltodecrypt=`tail "$DIR"/../logs/freenode_gribble.log | grep 'Get your encrypted OTP' | python -c 'import sys ; print sys.stdin.readlines()[-1].split()[-1].strip()'`
texttodecrypt=`wget -qO /dev/stdout "$urltodecrypt"`
decryptedtext=`echo "$texttodecrypt" | gpg --decrypt || true`
qdbus org.kde.konversation /irc say Freenode gribble "gpg everify $decryptedtext"
