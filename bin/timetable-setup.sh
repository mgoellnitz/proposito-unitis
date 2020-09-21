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
LIBDIR=$MYDIR/../shared/proposito-unitis
source $LIBDIR/lib.sh

if [ -z "$ZENITY" ] ; then
  echo -n "$(message "host"): "
  read UNTIS_HOST
  echo -n "$(message "code"): "
  read UNTIS_SCHOOL
else
  UNTIS_HOST=$($ZENITY --entry --text="$(message "host")" --entry-text="$UNTIS_HOST" --title="Untis"|sed -e 's/\r//g')
  UNTIS_SCHOOL=$($ZENITY --entry --text="$(message "code")" --entry-text="$UNTIS_SCHOOL" --title="Untis"|sed -e 's/\r//g')
fi

default "UNTIS_HOST" "$UNTIS_HOST"
default "UNTIS_SCHOOL" "$UNTIS_SCHOOL"
