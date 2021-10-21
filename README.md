# Untis related Command Line Tools

[![License](https://img.shields.io/github/license/mgoellnitz/proposito-unitis.svg)](https://github.com/mgoellnitz/proposito-unitis/blob/master/LICENSE)
[![Build](https://img.shields.io/gitlab/pipeline/backendzeit/proposito-unitis.svg)](https://gitlab.com/backendzeit/proposito-unitis/pipelines)
[![Download](https://img.shields.io/badge/Download-Snapshot-blue)](https://gitlab.com/backendzeit/proposito-unitis/-/jobs/artifacts/master/download?job=build)

"Hacking Untis for Fun and ... whatever."

This repository is to hack around certain limitations in the Untis accounts we 
have access to. It uses a parsed web-frontend and not the app backend so far.

The scripts are mainly used with GNU/Linux but are also partially tested with
OS X and also Windows Systems with a `Windows Subsystem for Linux` and a Debian
distribution install from the store on top of that.

A limited GUI feeling is achived through simple dialog-to-shell tools
(`zenity`) for GNU/Linux, Windows, and OS X (via `AppleScript`).


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

After downloading and extracting the archive 

### On Windows Systems 

Double click `install.bat`. When asked for a password, use the one given for 
the `WSL` user. Also answer the questions about the backend system in use.

### On Linux and OS X Systems

call `./install.sh` in the top level directory and answer the questions.

(This installation method is not meant to be the most elegant way.)

### Blind Installation

The afforementioned way is also implemented as a script to be directly 
downloaded and called by issuing

```
bash -c "$(curl -fsSL https://raw.githubusercontent.com/mgoellnitz/proposito-unitis/master/blind-install.sh)"
```


## Usage

Derived from the main command to fetch four weeks of timetable data for
integration with calendar systems, subsequent selection commands are added.
Four weeks will provide you with a view across vacations - except the
end of the term.

Fetching timetable data can be achieved in two ways:

* Web access via a simulated login and export of ICS-data
* Use of the published timetable calendar URL to retriev ICS-data

The first one is always possible and resembles clicks on the export button
of four consecutive weeks in the web frontend. The latter requires that you
pubilshed your timetable in the profile area of untis first.

Windows users double-click the commands from the windows folder of the
installation.

* Fetch four weeks time table data

Due to limitations in knownledge or the backend, only one week of time table
data can be fetched at once. So this is a rolling calendar switching to next 
week's data on saturdays.

```
Usage: fetchtimetable.sh [-i] [-s school] [-h host] [-p password] [-o filename] username
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

If you don't have the option to publish your calendar, you could use this on a
webserver and use the corresponding URL to integrate resulting the calendar ICS
file with any common calendar tool or mobile calendar.

* Fetch calendar data from export URL

If your calendar is published as optionally activated in your personal profile,
or if you have a fixed URL of any other source to retrieve untis timetable
information from, you can issue the URL instead of the username

```
fetchtimetable.sh [-o filename] URL
```

to fetch the timetable data.

Also in this case you can set the resulting URL to the environment variable
`UNTIS_URS` to avoid entering any parameters to `fetchtimetable.sh` at all.

* Find next lesson

Using the already fetched timetable data, it is possible to find out the next
starting time of a lesson for a given school subject or form.

```
Usage: next-lesson.sh -f form -s subject
```

The defaults are read from the environment variables `$SCHOOL_FORM` and
`$SCHOOL_SUBJECT` respectively. The output will be the starting time of the 
given lesson or `?` if the subject or form cannot be found in the timetable 
data. At least form or subject need to be given.

Examples:

```
# Next lesson in 11th form
next-lesson.sh -f 11
Mo 21. Sep 09:40:00 CEST 2020

# Next Maths lesson
next-lesson.sh -s Mat
Di 22. Sep 09:40:00 CEST 2020

# Next Maths lesson in 11th form - relevant for teachers
next-lesson.sh -f 11 -s Bio
Mo 21. Sep 13:40:00 CEST 2020
```


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

This is a arbitrary collection of repositories relating to [Untis][untis].

* https://github.com/SapuSeven/BetterUntis
* https://github.com/makubi/SchoolPlanner4Untis

[untis]: https://www.untis.at/
[issues]: https://gitlab.com/backendzeit/proposito-unitis/-/issues
[gitlab]: https://gitlab.com/backendzeit/proposito-unitis
[github]: https://github.com/mgoellnitz/proposito-unitis
