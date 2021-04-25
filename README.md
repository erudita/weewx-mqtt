# weewx-mqtt

This docker container can be used to quickly stand up a [WeeWX](http://weewx.com) instance.

WeeWx standard inclusions:
Ephem
MySql

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
