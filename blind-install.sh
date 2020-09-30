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
cd /tmp
rm -rf proposito-unitis
curl -Lo proposito-unitis.zip https://gitlab.com/backendzeit/proposito-unitis/-/jobs/artifacts/master/download?job=build 2> /dev/null
unzip -q proposito-unitis.zip
mv Untis* proposito-unitis
rm -f proposito-unitis.zip
cd proposito-unitis
./install.sh
