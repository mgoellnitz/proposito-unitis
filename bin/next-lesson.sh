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
MYDIR=`dirname $0`
LIBDIR=$MYDIR/../share/proposito-unitis
source $LIBDIR/lib.sh

TMPFILE=~/.untis-timetable.ics
DATEFILE="/tmp/date.list"
if [ -z "$(uname -v|grep Darwin)" ] ; then
  ZULU=""
else
  ZULU="zulu"
fi

function usage {
   echo "Usage: $MYNAME [-z] [-t file] -f form -s subject"
   echo ""
   echo "  -f form      form to filter output for"
   echo "  -s subject   school subject to filter output for"
   echo "  -t file      timetable file (downloaded with fetchtimetable)"
   echo "  -l language  set ISO-639 language code for output messages (except this one)"
   echo "  -k           use plain console version without dialogs"
   echo "  -z           don't format time but use simple standard UTC based output"
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
    SCHOOL_FORM="$1"
  fi
  if [ "$1" = "-k" ] ; then
    GUI=
    ZENITY=
  fi
  if [ "$1" = "-l" ] ; then
    shift
    LANGUAGE=${1}
  fi
  if [ "$1" = "-s" ] ; then
    shift
    SCHOOL_SUBJECT="$1"
  fi
  if [ "$1" = "-t" ] ; then
    shift
    TMPFILE="$1"
  fi
  if [ "$1" = "-z" ] ; then
    ZULU="zulu"
  fi
  shift
  PSTART=$(echo $1|sed -e 's/^\(.\).*/\1/g')
done

if [ ! -f $TMPFILE ] ; then
  text_info error no_timetable
  exit 1
fi

if [ -z "$(uname -v|grep Darwin)" ] ; then
  AGE=$[ $(date +%s) - $(stat -t $TMPFILE |cut -d ' ' -f 14) ]
else
  AGE=$[ $(date +%s) - $(eval $(stat -s $TMPFILE) ; echo $st_mtime) ]
fi
if [ "$AGE" -gt 518400 ] ; then
  text_info error no_timetable
  exit 1
fi

if [ -z "$SCHOOL_SUBJECT" ] ; then
  if [ -z "$SCHOOL_FORM" ] ; then
    usage
    exit 1
  else
    cat $TMPFILE | grep -A3 -B5 DESCRIPTION:.*${SCHOOL_FORM}|grep DTSTART > $DATEFILE
  fi
else
  if [ -z "$SCHOOL_FORM" ] ; then
    cat $TMPFILE | grep -i -A2 -B6 SUMMARY:.*${SCHOOL_SUBJECT}|grep DTSTART > $DATEFILE
  else
    cat $TMPFILE | grep -A3 -B5 DESCRIPTION:.*${SCHOOL_FORM}|grep -i -B4 SUMMARY:.*${SCHOOL_SUBJECT}|grep DTSTART > $DATEFILE
  fi
fi
if [ $(cat $DATEFILE|wc -l) -eq 0 ] ; then
  echo "?"
  exit 1
fi
if [ -z "$(uname -v|grep Darwin)" ] ; then
  MARKDATE=$(date -d "+1  days" +%Y%m%dT)
else
  MARKDATE=$(date -jf "%s" $[ $(date "+%s") + 86400 ] "+%Y%m%dT")
fi
MARK="DTSTART:$MARKDATE"
echo $MARK>> $DATEFILE
ZTIME=$(cat $DATEFILE|sort|grep -A1 $MARK|head -2|tail -1|cut -d ':' -f 2|sed -e 's/T/ /g'|sed -e 's/..Z//g')
# echo $ZTIME
if [ -z "$ZULU" ] ; then
  date -d "TZ=\"UTC\" $ZTIME"
else
  echo $ZTIME
fi
rm $DATEFILE
