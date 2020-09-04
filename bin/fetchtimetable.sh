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
   echo "Usage: $MYNAME -s school -h host -p password username"
   echo ""
   echo "  username   login of the user"
   echo "  school     untis UNTIS_SCHOOL for the given untis host (defaults to \$UNTIS_SCHOOL)"
   echo "  host       fqdn of the untis endpoint (defaults to \$UNTIS_HOST)"
   echo "  password   password for unti web login"
   echo ""
   exit
}

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
  shift
  PSTART=$(echo $1|sed -e 's/^\(.\).*/\1/g')
done
USERNAME=${1}

if [ -z "$USERNAME" ] ; then
  usage
fi

if [ -z "$UNTIS_SCHOOL" ] ; then
   echo "Error: Untis UNTIS_SCHOOL must be given as a parameter or by environment variable UNTIS_SCHOOL."
   exit
fi

if [ -z "$UNTIS_HOST" ] ; then
   echo "Error: Untis Host must be given as a parameter or by environment variable UNTIS_HOST."
   exit
fi

if [ -z $PASSWORD ] ; then
  echo -n "Password for $USERNAME@$UNTIS_HOST/$UNTIS_SCHOOL: "
  read -s PASSWORD
fi

rm -f ~/.untis.cookies.$USERNAME
echo "$UNTIS_HOST" > ~/.untis.host.$USERNAME
DATA=$(curl -c ~/.untis.cookies.$USERNAME -X POST -D - \
            -d "school=${UNTIS_SCHOOL}&j_username=${USERNAME}&j_password=${PASSWORD}&token=" https://${UNTIS_HOST}/WebUntis/j_spring_security_check 2> /dev/null)
curl -b ~/.untis.cookies.$USERNAME "https://${UNTIS_HOST}/WebUntis/Ical.do?elemType=5&elemId=455&rpt_sd="$(date -d "+2 days" +%Y-%m-%d) 2> /dev/null
