@echo off
set NANO=lib\nanohttpd-2.3.1.jar
set CLASSPATH=%NANO%
set class=%1%
echo %class%
if defined class ( java --enable-preview -cp %CLASSPATH%;classes %class%) else  @(
 echo Provide a class name)