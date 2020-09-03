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

USERNAME=${1}
SCHOOLNAME=${2:-$UNTIS_SCHOOL}
BACKEND=${3:-$UNTIS_HOST}
PASSWORD=${4}

function usage {
   echo "Usage: $MYNAME username school [untis host]"
   echo ""
   echo "  username    login of the user"
   echo "  school      untis schoolname for the given untis host"
   echo "  untis host  fqdn of the untis endpoint"
   echo ""
   exit
}

if [ -z "$USERNAME" ] ; then
  usage
fi

if [ -z "$SCHOOLNAME" ] ; then
   echo "Error: Untis Schoolname must be given as a second parameter or by environment variable UNTIS_SCHOOL."
   exit
fi

if [ -z "$BACKEND" ] ; then
   echo "Error: Untis Host must be given as a third parameter or by environment variable UNTIS_HOST."
   exit
fi

if [ -z $PASSWORD ] ; then
  echo -n "Password for $USERNAME@$BACKEND/$SCHOOLNAME: "
  read -s PASSWORD
fi

# echo Creating session for $USERNAME@$BACKEND
echo "$BACKEND" > ~/.session.$USERNAME
rm -f ~/.untis.$USERNAME

DATA=$(curl -c ~/.untis.$USERNAME -X POST -D - \
            -d "school=${SCHOOLNAME}&j_username=${USERNAME}&j_password=${PASSWORD}&token=" https://${BACKEND}/WebUntis/j_spring_security_check 2> /dev/null)
# echo "$DATA"
curl -b ~/.untis.$USERNAME "https://${BACKEND}/WebUntis/Ical.do?elemType=5&elemId=455&rpt_sd="$(date -d "+2 days" +%Y-%m-%d)
