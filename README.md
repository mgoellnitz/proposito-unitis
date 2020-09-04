# Untis related Command Line Tools

[![License](https://img.shields.io/github/license/mgoellnitz/proposito-unitis.svg)](https://github.com/mgoellnitz/proposito-unitis/blob/master/LICENSE)
[![Build](https://img.shields.io/gitlab/pipeline/backendzeit/proposito-unitis.svg)](https://gitlab.com/backendzeit/proposito-unitis/pipelines)

"Hacking Untis for Fun and ... whatever."

This repository is to hack around certain limitations in the Untis accounts we 
have access to. It uses a parsed web-frontend and not the app backend so far.

Sorry to tell you that due to personal preferences in our household all these
scripts are and will be only linux-tested.

## Feedback

This repository is available at [github][github] and [gitlab][gitlab]. Please 
prefer the [issues][issues] section of this repository at [gitlab][gitlab]
for feedback.

## Naming

The name is just a pun on `viribus unitis` reflecting the fact, that we are
mainly dealing with a time table here and that it sounds similar to untis.

## Usage

Currently there is only one command available:

* Fetch this weeks time table

Due to limitations in knownledge or the backend, only one week of time table
data can be fetched at once. So this is a rolling calendar switching to next 
week's data on saturdays.

```
Usage: fetchtimetable.sh -s school -h host -p password username
```

The school has to be given as the Untis school code, not name. The optional
parameter for the password is for for purposes like cron-jobs:

```
7 */2 * * * /home/www/fetchtimetable.sh -s xy1234 -h some.untis -p secret sus.or.lol > /var/www-data/somewhere/my.ics
```

With this running on a webserver, you can use the corresponding URL to 
integrate the calender with any common calendar tool or mobile calendar.

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
