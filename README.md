# weewx-mqtt

This docker container can be used to stand up a [WeeWX](http://weewx.com) instance.

## Principles ##
This is for a user that wants to:
* Run weewx in a Docker container
* Edit the config file weewx.conf directly
* Change skins by direct edits
* Create html and images as part of standard runs
* Export HTML to external web servers
* **Only** get input from an Observer-like (i.e. IP) source, ignoring USB or serial feeds
  [note that serial/usb drivers are simply commented out in the build]

## WeeWx inclusions:##
Standard:
* Ephem
* MySql

This container has the following WeeWX extensions installed:

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
