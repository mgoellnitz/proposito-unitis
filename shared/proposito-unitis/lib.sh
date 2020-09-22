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

# localized message translation $1 is a message key
function message {
  if [ -z "$LANGUAGE" ] ; then
    LANGUAGE=$(echo $LANG|cut -d '_' -f 1)
    if [ -z "$LANGUAGE" ] ; then
      LANGUAGE="de"
    fi
  fi
  FILENAME=$LIBDIR/messages_$LANGUAGE.txt
  if [ ! -f "$FILENAME" ] ; then
    FILENAME=$LIBDIR/messages.txt
  fi
  
  if [ ! -z "$1" ] ; then
    RESULT=$(grep ^$1= $FILENAME|sed -e "s/^$1=\(.*\)$/\1/g")
  fi
  if [ -z "$RESULT" ] ; then
    RESULT=$1
  fi
  echo $RESULT
}

# $1 title $2 text
function text_info {
  if [ -z "$ZENITY" ] ; then
    echo -n "$(message "$2"): "
  else
    $ZENITY --info --title="$(message "$1")" --text="$(message "$2")" --no-wrap
  fi
}

# $1 title $2 text $3 default
function text_input {
  if [ -z "$ZENITY" ] ; then
    echo -n "$(message "$2"): "
    read RESULT
  else
    RESULT=$($ZENITY --entry --title="$(message "$1")" --text="$(message "$2")" --entry-text="$3"|sed -e 's/\r//g')
  fi
  echo $RESULT
}

# $1 title $2 text $3 default
function password_input {
  if [ -z "$ZENITY" ] ; then
    echo -n "$(message "$2"): "
    read -s RESULT
  else
    RESULT=$($ZENITY --entry --title="$(message "$1")" --text="$(message "$2")" --entry-text="$3" --hide-text|sed -e 's/\r//g')
  fi
  echo $RESULT
}

# set default $1 in .bashrc to value $2
function default {
  grep -v "${1}=" ~/.bashrc > brc 
  mv brc ~/.bashrc
  echo "export ${1}=${2}" >> ~/.bashrc
}
