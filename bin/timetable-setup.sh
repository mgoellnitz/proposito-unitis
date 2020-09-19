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
WINDOWS=$(uname -a|grep Microsoft)
if [ ! -z "$WINDOWS" ] ; then
  ZENITY=zenity.exe
else
  ZENITY=zenity
fi
if [ -z "$(which zenity)" ] ; then
  ZENITY=
fi

if [ -z "$ZENITY" ] ; then
  echo -n "Untis Host: "
  read UNTIS_HOST
  echo -n "Untis School Code: "
  read UNTIS_SCHOOL
else
  UNTIS_HOST=$($ZENITY --entry --text="Backend Hostname" --entry-text="$UNTIS_HOST" --title="Untis"|sed -e 's/\r//g')
  UNTIS_SCHOOL=$($ZENITY --entry --text="Schulcode" --entry-text="$UNTIS_SCHOOL" --title="Untis"|sed -e 's/\r//g')
fi

grep -v UNTIS_HOST= ~/.bashrc > brc 
mv brc ~/.bashrc
echo "export UNTIS_HOST=$UNTIS_HOST" >> ~/.bashrc
grep -v UNTIS_SCHOOL= ~/.bashrc > brc 
mv brc ~/.bashrc
echo "export UNTIS_SCHOOL=$UNTIS_SCHOOL" >> ~/.bashrc
