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
CHECK=$((which curl;which unzip;which zenity)|wc -l)
if [ "$CHECK" -lt 3 ] ; then
  if [ "$(which apt|wc -l)" -eq 1 ] && [ -z "$(uname -v|grep Darwin)" ] ; then
    sudo apt update
    sudo apt install -yq curl unzip zenity
  else
    if [ "$((which curl;which unzip)|wc -l)" -lt 2 ] ; then
      echo 'Please ensure that unzip and curl are available from the $PATH'
    fi
  fi
fi
if [ -w /usr/local/bin/timetable-setup.sh ] ; then
  cp -p bin/*.sh /usr/local/bin
  cp -rp share/* /usr/local/share
else
  sudo cp -p bin/*.sh /usr/local/bin
  sudo cp -rp share/* /usr/local/share
fi
MYDIR=$(dirname $BASH_SOURCE)|sed -e 's/install\///g'|sed -e 's/^.bin/\./g'
if [ -z "$MYDIR" ] ; then
  MYDIR="."
fi
LIBDIR=$MYDIR/share/proposito-unitis
source $MYDIR/share/proposito-unitis/lib.sh
PSTART=`echo $1|sed -e 's/^\(.\).*/\1/g'`
while [ "$PSTART" = "-" ] ; do
  if [ "$1" = "-l" ] ; then
    shift
    set_language "$1" "$LANGUAGE" lock
  fi
  shift
  PSTART=`echo $1|sed -e 's/^\(.\).*/\1/g'`
done
if [ ! -z "$WINDOWS" ] && [ ! -f /usr/local/bin/zenity.exe ] ; then
  curl -Lo zenity.zip https://github.com/maravento/winzenity/raw/master/zenity.zip 2> /dev/null
  unzip zenity.zip
  sudo mv zenity.exe /usr/local/bin
  rm zenity.zip
fi
if [ ! -z "$(uname -v|grep Darwin)" ] ; then
  if [ -z "$(grep source....bashrc ~/.bash_profile)" ] ; then
    echo 'if [ -s ~/.bashrc ]; then source ~/.bashrc; fi' >> ~/.bash_profile
  fi
fi
if [ -z "$UNTIS_HOST" ] ; then
  timetable-setup.sh
  $(text_info installation installation_completed)
fi
