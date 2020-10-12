@echo off
if exist classes (rmdir /S /Q classes)
set NANOLETS=lib\nanohttpd-nanolets-2.3.1.jar
set WEBSERVER=lib\nanohttpd-webserver-2.3.1.jar
set NANO=lib\nanohttpd-2.3.1.jar
set SERVLET=lib\javax.servlet-api-4.0.1.jar
set WEBSOCKET=lib\nanohttpd-websocket-2.3.1.jar

set CLASSPATH=%NANO%;%SERVLET%;%NANOLETS%;%WEBSERVER%;%WEBSOCKET%

javac -d classes  --enable-preview --release 14 -cp %CLASSPATH%;classes src\*.java

