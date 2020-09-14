# Untis related Command Line Tools

[![License](https://img.shields.io/github/license/mgoellnitz/proposito-unitis.svg)](https://github.com/mgoellnitz/proposito-unitis/blob/master/LICENSE)
[![Build](https://img.shields.io/gitlab/pipeline/backendzeit/proposito-unitis.svg)](https://gitlab.com/backendzeit/proposito-unitis/pipelines)
[![Download](https://img.shields.io/badge/Download-Snapshot-blue)](https://gitlab.com/backendzeit/proposito-unitis/-/jobs/artifacts/master/download?job=build)

"Hacking Untis for Fun and ... whatever."

This repository is to hack around certain limitations in the Untis accounts we 
have access to. It uses a parsed web-frontend and not the app backend so far.

The scripts are mainly used with GNU/Linux  but are also partially tested with
a Windows Subsystem for Linux and a Debian install from the store on top of
that.

## Feedback

This repository is available at [github][github] and [gitlab][gitlab]. Please 
prefer the [issues][issues] section of this repository at [gitlab][gitlab]
for feedback.

## Naming

The name is just a pun on `viribus unitis` reflecting the fact, that we are
mainly dealing with a time table here and that it sounds similar to untis.

## Windows Integration

The use of this tool with windows is possible but limited to systems where the
Windows Subsystem for Linux (WSL) is installed and a linux distribution
`Debian` or `Ubuntu` is installed from the Store.

## Installation

Besides the usual manual mode if extracting the files from the distribution
archive to a place of your chosing and add this to you PATH, a short version
for inexperiences users is presented especially on Windows (WSL) systems.

After downloading and extracting the archive call `./install.sh` in the top
level directory or double-click `install.bat`.

(This installation method is not meant to be the most elegant way.)

## Usage

Derived from the main command to fetch two weeks of timetable data for
integration with calendar systems, subsequent selection commands are added.

Windows users double-click the commands from the windows folder of the
installation.

* Fetch two weeks time table data

Due to limitations in knownledge or the backend, only one week of time table
data can be fetched at once. So this is a rolling calendar switching to next 
week's data on saturdays.

```
Usage: fetchtimetable.sh [-i] [-s school] [-h host] [-p password] [-o filename] username_or_URL
```

If you prefer some - potentially GUI based - guidance, use the interactive mode
with the `-i` option.

The school has to be given as the Untis school code, not name. The school
parameter uses a default value given by the environment variable $UNTIS_SCHOOL
and the host uses the environment variable $UNTIS_HOST as a default. If no
output file name is given, `untis-timetable.ics` is used. If no password is
issued, you will be prompted to enter one.

One example usage would be to place this command with a full set of command
line argument in a cron-job:
```
7 */2 * * * /home/www/fetchtimetable.sh -s xy1234 -h some.untis -p secret -o /var/www-data/somewhere/my.ics sus.or.lol
```

With this running on a webserver, you can use the corresponding URL to 
integrate the calender with any common calendar tool or mobile calendar.

* Fetch calendar data from export URL

If you don't need the web export and have a fixed URL to fetch equivalent
timetable data from, you can issue a URL instead of the user's login name
or even store this in the environment variable `UNTIS_URL`.

* Find next lesson

Using the already fetched timetable data, it is possible to find out the next
starting time of a lesson for a given school subject or form.

```
Usage: next-lesson.sh -f form -s subject
```

The defaults are read from the environment variables $SCHOOL_FORM and
$SCHOOL_SUBJECT respectively. The output will be the starting time of the given
lesson or `?` if the subject or form cannot be found in the timetable data.

## Context Switches

For convenience the environment variables defining your school code and host to use

Especially in Teacher View many parameters will be needed and be mostly
constant over a given period in time. To avoid this, some parameters may be
given as environment variables.

Those variables may be modified in your shell defaults with some convenience
scripts.

* Setup basic Parameters

```
./timetable-setup.sh
Untis Host: stundenplan.hamburg.de
Untis School Code: hh5848
```

## References

The project avatar is taken from DarkWorkX @ Pixabay.

## Related Repositories on Github

This is a deliberate collection of repositories relating to [Untis][untis].

* https://github.com/SapuSeven/BetterUntis
* https://github.com/makubi/SchoolPlanner4Untis

[untis]: https://www.untis.at/
[issues]: https://gitlab.com/backendzeit/proposito-unitis/-/issues
[gitlab]: https://gitlab.com/backendzeit/proposito-unitis
[github]: https://github.com/mgoellnitz/proposito-unitis
