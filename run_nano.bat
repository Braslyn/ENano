@echo off
set NANOLETS=lib\nanohttpd-nanolets-2.3.1.jar
set WEBSERVER=lib\nanohttpd-webserver-2.3.1.jar
set NANO=lib\nanohttpd-2.3.1.jar
set SERVLET=lib\javax.servlet-api-4.0.1.jar
set WEBSOCKET=lib\nanohttpd-websocket-2.3.1.jar

set CLASSPATH=%NANO%;%SERVLET%;%NANOLETS%;%WEBSERVER%;%WEBSOCKET%

set class=%1%
echo %class%

if defined class ( java --enable-preview -cp %CLASSPATH%;classes %class%) else  @(
 echo Provide a class name)