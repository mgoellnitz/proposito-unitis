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

TMPFILE="untis-timetable.ics"
DATEFILE="/tmp/date.list"
ZULU=""

function usage {
   echo "Usage: $MYNAME [-z] [-t file] -f form -s subject"
   echo ""
   echo "  -f form     form to filter output for"
   echo "  -s subject  school subject to filter output for"
   echo "  -t file     timetable file (downloaded with fetchtimetable)"
   echo "  -z          don't format time but use simple standard UTC based output"
   echo ""
   exit
}


PSTART=$(echo $1|sed -e 's/^\(.\).*/\1/g')
while [ "$PSTART" = "-" ] ; do
  if [ "$1" = "-h" ] ; then
    usage
  fi
  if [ "$1" = "-f" ] ; then
    shift
    export SCHOOL_FORM="$1"
  fi
  if [ "$1" = "-s" ] ; then
    shift
    export SCHOOL_SUBJECT="$1"
  fi
  if [ "$1" = "-t" ] ; then
    shift
    export TMPFILE="$1"
  fi
  if [ "$1" = "-z" ] ; then
    export ZULU="zulu"
  fi
  shift
  PSTART=$(echo $1|sed -e 's/^\(.\).*/\1/g')
done

if [ -z "$SCHOOL_FORM" ] ; then
  if [ -z "$SCHOOL_SUBJECT" ] ; then
    usage
    exit 1
  fi
fi

if [ ! -f $TMPFILE ] ; then
  echo "No timetable file $TMPFILE available. Please fetch current timetable data first."
  exit 1
fi

if [ -z "$SCHOOL_SUBJECT" ] ; then
  if [ -z "$SCHOOL_FORM" ] ; then
    echo ""
  else
    cat $TMPFILE | grep -A3 -B6 DESCRIPTION:.*${SCHOOL_FORM}|grep DTSTART
    cat $TMPFILE | grep -A3 -B6 DESCRIPTION:.*${SCHOOL_FORM}|grep DTSTART > $DATEFILE
  fi
else
  if [ -z "$SCHOOL_FORM" ] ; then
    cat $TMPFILE | grep -i -A2 -B7 SUMMARY:.*${SCHOOL_SUBJECT}|grep DTSTART > $DATEFILE
  else
    cat $TMPFILE | grep -A3 -B6 DESCRIPTION:.*${SCHOOL_FORM}|grep -i -B5 SUMMARY:.*${SCHOOL_SUBJECT}|grep DTSTART > $DATEFILE
  fi
fi
if [ $(wc -l $DATEFILE|cut -d ' ' -f 1) -eq 0 ] ; then
  echo "?"
  exit 1
fi
MARK="$(grep DTSTART $TMPFILE |tail -1|cut -d ':' -f 1):$(date -d '+1 day' +%Y%m%dT)"
echo $MARK>> $DATEFILE
cat $DATEFILE|sed 's/\r$//g'|sort|grep -A1 "$MARK"
echo ""
# TODO: Add TIMEZONE discovery here
ZTIME=$(cat $DATEFILE|sed 's/\r$//g'|sort|grep -A1 "$MARK"|head -2|tail -1|cut -d ':' -f 2|sed -e 's/\(T[0-9][0-9][0-9][0-9]\)[0-9][0-9]$/\1/g'|sed -e 's/T/ /g'|sed -e 's/..Z//g')
echo $ZTIME
TZ="$(cat $DATEFILE|sort|grep -A1 "$MARK"|head -2|tail -1|cut -d ':' -f 1|sed -e 's/DTSTART//g'|sed -e 's/;TZID=/TZ="/g')"
echo $TZ
if [ -z "$ZULU" ] ; then
  if [ -z TZ ] ; then
    date -d "TZ=\"UTC\" $ZTIME"
  else
    TZ="$TZ\""
    date -d "$TZ $ZTIME"
  fi
else
  if [ -z TZ ] ; then
    echo $ZTIME
  else
    TZ="$TZ\""
    echo $ZTIME
  fi
fi
# rm $DATEFILE
