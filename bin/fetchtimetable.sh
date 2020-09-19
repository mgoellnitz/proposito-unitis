#!/bin/bash
#
# Copyright 2020 Martin Goellnitz
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

function usage {
   echo "Usage: $MYNAME [-i] [-s school] [-h host] [-p password] [-o filename] username_or_URL"
   echo ""
   echo "  -i                  interactive"
   echo "     username_or_URL  login of the user or full URL to fetch an equivalent calender"
   echo "  -s school           untis UNTIS_SCHOOL for the given untis host (defaults to \$UNTIS_SCHOOL)"
   echo "  -h host             fqdn of the untis endpoint (defaults to \$UNTIS_HOST)"
   echo "  -p password         password for untis web login"
   echo "  -o filename         name of the output file (defaults to untis-schedule.ics)"
   echo ""
   exit
}

OUTFILE=untis-timetable.ics
PSTART=$(echo $1|sed -e 's/^\(.\).*/\1/g')
while [ "$PSTART" = "-" ] ; do
  if [ "$1" = "-s" ] ; then
    shift
    export UNTIS_SCHOOL="$1"
  fi
  if [ "$1" = "-h" ] ; then
    shift
    export UNTIS_HOST="$1"
  fi
  if [ "$1" = "-p" ] ; then
    shift
    export PASSWORD="$1"
  fi
  if [ "$1" = "-o" ] ; then
    shift
    export OUTFILE="$1"
  fi
  if [ "$1" = "-i" ] ; then
    INTERACTIVE=true
  fi
  shift
  PSTART=$(echo $1|sed -e 's/^\(.\).*/\1/g')
done
USERNAME=${1:-$UNTIS_URL}

if [ -z "$UNTIS_SCHOOL" ] ; then
   echo "Error: Untis UNTIS_SCHOOL must be given as a parameter or by environment variable UNTIS_SCHOOL."
   exit
fi

if [ -z "$UNTIS_HOST" ] ; then
   echo "Error: Untis Host must be given as a parameter or by environment variable UNTIS_HOST."
   exit
fi

WINDOWS=$(uname -a|grep Microsoft)
if [ ! -z "$WINDOWS" ] ; then
  ZENITY=zenity.exe
else
  ZENITY=zenity
fi
if [ -z $(which zenity) ] ; then
  ZENITY=
fi

if [ -z "$USERNAME" ] ; then
  if [ -z "$INTERACTIVE" ] ; then
    usage
  else
    if [ -z "$ZENITY" ] ; then
      echo -n "Username for $UNTIS_HOST/$UNTIS_SCHOOL: "
      read USERNAME
    else
      USERNAME=$($ZENITY --entry --text="Nutzername oder URL" --entry-text="$UNTIS_URL" --title="Untis"|sed -e 's/\r//g')
    fi
    if [ -z "$USERNAME" ] ; then
      usage
    fi
  fi
fi

if [ "$(echo $USERNAME|grep ':'|wc -l)" -gt 0 ] ; then
  curl "$USERNAME" 2> /dev/null > $OUTFILE
else
  if [ -z $PASSWORD ] ; then
    if [ -z "$ZENITY" ] ; then
      echo -n "Password for $USERNAME@$UNTIS_HOST/$UNTIS_SCHOOL: "
      read -s PASSWORD
    else
      PASSWORD=$($ZENITY --entry --text="Kennwort" --entry-text="$PASSWORD" --hide-text --title="Untis"|sed -e 's/\r//g')
    fi
  fi

  rm -f ~/.untis.cookies.$USERNAME
  # echo "$UNTIS_HOST" > ~/.untis.host.$USERNAME
  DATA=$(curl -c ~/.untis.cookies.$USERNAME -X POST -D - \
              -d "school=${UNTIS_SCHOOL}&j_username=${USERNAME}&j_password=${PASSWORD}&token=" https://${UNTIS_HOST}/WebUntis/j_spring_security_check 2> /dev/null)

  curl -b ~/.untis.cookies.$USERNAME "https://${UNTIS_HOST}/WebUntis/Ical.do?elemType=5&elemId=455&rpt_sd="$(date -d "+2  days" +%Y-%m-%d) 2> /dev/null |grep -v END.VCALENDAR> $OUTFILE
  curl -b ~/.untis.cookies.$USERNAME "https://${UNTIS_HOST}/WebUntis/Ical.do?elemType=5&elemId=455&rpt_sd="$(date -d "+9  days" +%Y-%m-%d) 2> /dev/null |grep -v VCALENDAR|grep -v PRODID:|grep -v VERSION:|grep -v CALSCALE:>> $OUTFILE
  curl -b ~/.untis.cookies.$USERNAME "https://${UNTIS_HOST}/WebUntis/Ical.do?elemType=5&elemId=455&rpt_sd="$(date -d "+16 days" +%Y-%m-%d) 2> /dev/null |grep -v VCALENDAR|grep -v PRODID:|grep -v VERSION:|grep -v CALSCALE:>> $OUTFILE
  curl -b ~/.untis.cookies.$USERNAME "https://${UNTIS_HOST}/WebUntis/Ical.do?elemType=5&elemId=455&rpt_sd="$(date -d "+23 days" +%Y-%m-%d) 2> /dev/null |grep -v BEGIN.VCALENDAR|grep -v PRODID:|grep -v VERSION:|grep -v CALSCALE:>> $OUTFILE
fi
