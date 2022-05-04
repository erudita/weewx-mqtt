# weewx-mqtt

This docker container can be used to stand up a [WeeWX](http://weewx.com) instance.

## Context ##

[WeeWX](http://weewx.com) is an open source software program which interacts weather stations to produce graphs, reports, and HTML pages with the option to publish to weather sites or web servers

## Purpose ##
This package is for a someone that wants to:
* Run weewx in a Docker container
* Store weewx archive in an external mysql database
* Edit the config file weewx.conf directly by storing confiuration in a mounted Volume
* Export HTML to external web servers
* Change the html skins by direct edits (external volume)
* Create HTML, images, and reports as part of standard runs and store these in a Volume
* Import Additional data from MQTT
* Export records to MQTT

* **Only** get input from an Observer-like (i.e. IP) source, ignoring USB or serial feeds
  [note that serial/usb drivers are simply commented out in the build]

## WeeWx inclusions ##
### Standard: ###
* Ephem
* MySql

### Weewx Extensions: ###

This container has the following WeeWX extensions installed:

* [interceptor](https://github.com/erudita/weewx-interceptor) forked from [interceptor](https://github.com/matthewwall/weewx-interceptor) for Ecowitt WH90
* [mqtt](https://github.com/weewx/weewx/wiki/mqtt)
* [mqttSubscribe](https://github.com/bellrichm/WeeWX-MQTTSubscribe)

## Input Sources ##
* ~~USB driver~~
* ~~Serial Driver~~
* Interceptor
* MQTTSubscribe

## Output ##
In addition to standard configurable output, such as FTP, various weather site updates, 

* MQTT (with mqtt)


## How to use ##
Create container with mount points for Volumes or fileshares thus:
| container mount point | contents | description |
| ------------ | -------- | ---------- |
| /data        | ./etc/weewx.conf | weewx configuration file | 
|              | ./archive/weewx.sdb | sqlite databases if configured |
|              | ./bin/entrypoint.sh | Docker entrypoint script (testing) | 
|              | ./skins              | weewx skins
| /public_html | \<files\> | generated web pages and images (can be changed in weewx.conf) |

Port 8080 is the default port used by Interceptor.
It will need to be exposed in some way (NAT, direct, etc.)

### Entrypoint.sh actions ###
* If there is no container file, /data/etc/weewx.conf, the distribution configuration is copied to that location and is modified to adjust location of databases and IP ports.
* If a local entrypoint.sh exists (./bin/entrypoint.sh) that executable is executed otherwise
* syslogd is started (as weewxd gets messy without it)
* weewxd is started

### weewx.conf ###
It is expected that weewx.conf be editied to suit.
