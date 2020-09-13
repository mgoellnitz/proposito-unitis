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
echo -n "Untis Host: "
read UNTIS_HOST
grep -v UNTIS_HOST= ~/.bashrc > brc 
mv brc ~/.bashrc
echo "export UNTIS_HOST=$UNTIS_HOST" >> ~/.bashrc
echo -n "Untis School Code: "
read UNTIS_SCHOOL
grep -v UNTIS_SCHOOL= ~/.bashrc > brc 
mv brc ~/.bashrc
echo "export UNTIS_SCHOOL=$UNTIS_SCHOOL" >> ~/.bashrc
source ~/.bashrc
