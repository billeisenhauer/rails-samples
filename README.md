ABOUT THIS REPO
===============

This repository is purely for those who might request a code sample or be
otherwise curious about some of my past code.  None of this code is rocket
science.  Some of it may be downright trivial or even embarrassing.  Context
is everything.

SuzanneCan
__________

This was a project I built for my wife.  Its little more than a few static 
pages and probably should have been a Wordpress site.  That said, there are
probably a few things that could be observed about the coding skills that I 
had when I wrote this (2009-ish):

* Tidy, tight controllers
* A dash of page caching
* Trivial, but organized models with a few named scopes
* Lean markup, well-factored views
* Routine capistrano
* A reasonable design which is not my strong suit
* Serviceable CSS; also not my strong suit, but decently executed in this case

Completions
___________

This project was built originally to track inventory for an Oil & Gas company.
The assets were RFID-tagged and this app received and reconciled tag readings
to provide inventory status.  Otherwise, its mostly a big spreadsheet.  

The app was deployed and ran quietly for a year or so before being retired.
It was deployed on a single server and had minimal traffic expectations.  

This was also 2009-ish.  Here are a few notes:

* Authlogic for authentication; LDAP integration
* Declarative authorization; looked at config/authorization_rules.rb
* Reasonably tight controllers, but some additional complexity
* Lots of named scopes; some of them on the complex side
* Scheduled cron jobs; look at app/utilities and config/schedule.rb
* Reasonable RSpec coverage
