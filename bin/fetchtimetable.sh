#!/bin/bash
#
# Copyright 2020-2021 Martin Goellnitz
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
MYNAME=`basename $0`
MYDIR=`dirname $0`
LIBDIR=$MYDIR/../share/proposito-unitis
source $LIBDIR/lib.sh
TMPFILE=~/.untis-timetable-t.ics
CFILE=~/.untis-timetable-c.ics

function usage {
   echo "Usage: $MYNAME [-i] [-s school] [-h host] [-p password] [-o filename] username_or_URL"
   echo ""
   echo "  -i                  interactive"
   echo "  -k                  use plain console version without dialogs"
   echo "  -c                  condense timetable - add description to location"
   echo "  -l language         set ISO-639 language code for output messages (except this one)"
   echo "     username_or_URL  login of the user or full URL to fetch an equivalent calender"
   echo "  -s school           untis UNTIS_SCHOOL for the given untis host (defaults to \$UNTIS_SCHOOL)"
   echo "  -h host             fqdn of the untis endpoint (defaults to \$UNTIS_HOST)"
   echo "  -p password         password for untis web login"
   echo "  -o filename         name of the output file (defaults to untis-schedule.ics)"
   echo ""
   exit
}

OUTFILE=~/.untis-timetable.ics
PSTART=$(echo $1|sed -e 's/^\(.\).*/\1/g')
while [ "$PSTART" = "-" ] ; do
  if [ "$1" = "-h" ] ; then
    shift
    UNTIS_HOST=${1}
  fi
  if [ "$1" = "-i" ] ; then
    INTERACTIVE=true
  fi
  if [ "$1" = "-c" ] ; then
    CONDENSE=true
  fi
  if [ "$1" = "-o" ] ; then
    shift
    OUTFILE=${1}
  fi
  if [ "$1" = "-k" ] ; then
    GUI=
    ZENITY=
  fi
  if [ "$1" = "-l" ] ; then
    shift
    set_language "$1" "$LANGUAGE" lock
  fi
  if [ "$1" = "-p" ] ; then
    shift
    PASSWORD=${1}
  fi
  if [ "$1" = "-s" ] ; then
    shift
    UNTIS_SCHOOL=${1}
  fi
  shift
  PSTART=$(echo $1|sed -e 's/^\(.\).*/\1/g')
done
USERNAME=${1:-$UNTIS_URL}

if [ -z "$USERNAME" ] ; then
  if [ -z "$INTERACTIVE" ] ; then
    usage
  else
    USERNAME=$(text_input Untis username_url "$UNTIS_URL")
    if [ -z "$USERNAME" ] ; then
      usage
    fi
  fi
fi

if [ "$(echo $USERNAME|grep ':'|wc -l)" -gt 0 ] ; then
  curl "$USERNAME" 2> /dev/null > $TMPFILE
else
  if [ -z "$UNTIS_SCHOOL" ] ; then
     echo $(message "no_school")
     exit
  fi

  if [ -z "$UNTIS_HOST" ] ; then
     echo $(message "no_host")
     exit
  fi

  if [ -z $PASSWORD ] ; then
    PASSWORD=$(password_input Untis "$(message "password_for") $USERNAME@$UNTIS_HOST/$UNTIS_SCHOOL" "$PASSWORD")
  fi

  rm -f ~/.untis.cookies.$USERNAME
  DATA=$(curl -c ~/.untis.cookies.$USERNAME -X POST -D - \
              -d "school=${UNTIS_SCHOOL}&j_username=${USERNAME}&j_password=${PASSWORD}&token=" https://${UNTIS_HOST}/WebUntis/j_spring_security_check 2> /dev/null)

  if [ -z "$(uname -v|grep Darwin)" ] ; then
    WEEK=$(date -d "+2  days" +%Y-%m-%d)
  else
    WEEK=$(date -jf "%s" $[ $(date "+%s") + (86400*2) ] "+%Y-%m-%d")
  fi

  # try teacher timetable
  ETYPE=2
  EID=$(curl -b ~/.untis.cookies.$USERNAME "https://${UNTIS_HOST}/WebUntis/api/public/timetable/weekly/pageconfig?type=2&date=$WEEK" 2> /dev/null \
             |grep 'selectedElementId":[0-9][0-9][0-9]*'|sed -e 's/^.*selectedElementId":\([0-9][0-9][0-9]*\).*$/\1/g')
  if [ -z "$EID" ] ; then
    # No teacher, select student timetable
    ETYPE=5
    EID=$(curl -b ~/.untis.cookies.$USERNAME "https://${UNTIS_HOST}/WebUntis/api/public/timetable/weekly/pageconfig?type=5&date=$WEEK" 2> /dev/null \
               |grep 'selectedElementId":[0-9][0-9][0-9]*'|sed -e 's/^.*selectedElementId":\([0-9][0-9][0-9]*\).*$/\1/g')
  fi
  if [ -z "$EID" ] ; then
    echo "$(message cannot_fetch)"
    exit 1
  fi

  curl -b ~/.untis.cookies.$USERNAME "https://${UNTIS_HOST}/WebUntis/Ical.do?elemType=$ETYPE&elemId=$EID&rpt_sd=$WEEK" 2> /dev/null |grep -v END.VCALENDAR> $TMPFILE
  if [ -z "$(uname -v|grep Darwin)" ] ; then
    WEEK=$(date -d "+9  days" +%Y-%m-%d)
  else
    WEEK=$(date -jf "%s" $[ $(date "+%s") + (86400*9) ] "+%Y-%m-%d")
  fi
  curl -b ~/.untis.cookies.$USERNAME "https://${UNTIS_HOST}/WebUntis/Ical.do?elemType=$ETYPE&elemId=$EID&rpt_sd=$WEEK" 2> /dev/null |grep -v VCALENDAR|grep -v PRODID:|grep -v VERSION:|grep -v CALSCALE:>> $TMPFILE
  if [ -z "$(uname -v|grep Darwin)" ] ; then
    WEEK=$(date -d "+16  days" +%Y-%m-%d)
  else
    WEEK=$(date -jf "%s" $[ $(date "+%s") + (86400*16) ] "+%Y-%m-%d")
  fi
  curl -b ~/.untis.cookies.$USERNAME "https://${UNTIS_HOST}/WebUntis/Ical.do?elemType=$ETYPE&elemId=$EID&rpt_sd=$WEEK" 2> /dev/null |grep -v VCALENDAR|grep -v PRODID:|grep -v VERSION:|grep -v CALSCALE:>> $TMPFILE
  if [ -z "$(uname -v|grep Darwin)" ] ; then
    WEEK=$(date -d "+23  days" +%Y-%m-%d)
  else
    WEEK=$(date -jf "%s" $[ $(date "+%s") + (86400*23) ] "+%Y-%m-%d")
  fi
  curl -b ~/.untis.cookies.$USERNAME "https://${UNTIS_HOST}/WebUntis/Ical.do?elemType=$ETYPE&elemId=$EID&rpt_sd=$WEEK" 2> /dev/null |grep -v BEGIN.VCALENDAR|grep -v PRODID:|grep -v VERSION:|grep -v CALSCALE:>> $TMPFILE
fi

if [ ! -z "$CONDENSE" ] ; then
  echo -n "" > $CFILE
  DESCRIPTION=""
  while IFS='' read -r LINE || [[ -n "$LINE" ]]; do
    LINE="$(echo $LINE|sed -e 's/\r//g')"
    # echo "Line $DESCRIPTION: $LINE"
    if [ ! -z "$(echo $LINE|grep '^DESCRIPTION:')" ] ; then
      DESCRIPTION="$(echo $LINE|sed -e 's/^DESCRIPTION://g')"
    fi
    echo $LINE|sed -e "s/^LOCATION:\(.*\)/LOCATION:$DESCRIPTION \1/g" >> $CFILE
  done < $TMPFILE
  mv $CFILE $TMPFILE
fi

mv $TMPFILE $OUTFILE
rm -f ~/.untis.cookies.$USERNAME
