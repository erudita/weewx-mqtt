# weewx-mqtt

This docker container can be used to stand up a [WeeWX](http://weewx.com) instance.

## Context ##

[WeeWX](http://weewx.com) is an open source software program which interacts weather stations to produce graphs, reports, and HTML pages with the option to publish to weather sites or web servers

## Purpose ##
This is for a user that wants to:
* Run weewx in a Docker container
* Edit the config file weewx.conf directly by stofing in a Volume
* Export HTML to external web servers
* Change the html skins by direct edits
* Create HTML, images, and reports as part of standard runs and store these in a Volume

* **Only** get input from an Observer-like (i.e. IP) source, ignoring USB or serial feeds
  [note that serial/usb drivers are simply commented out in the build]

## WeeWx inclusions ##
### Standard: ###
* Ephem
* MySql

This container has the following WeeWX extensions installed:

### Other: ###

* [interceptor](https://github.com/matthewwall/weewx-interceptor)
* [mqtt](https://github.com/weewx/weewx/wiki/mqtt)

## Input Feeds ##
* ~~USB driver~~
* ~~Serial Driver~~
* Interceptor

## Output ##
* MQTT
* FTP
* HTML (local)

## How to use ##
Create container with mount points for Volumes or fileshares thus:
- /data        (etc/weewx.conf, data/MSqllitedb)
- /public_html generated html/NOAA reports
