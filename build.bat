@echo off
if exist classes (rmdir /S /Q classes)
set NANO=lib\nanohttpd-2.3.1.jar
set CLASSPATH=%NANO%

javac -d classes -cp %CLASSPATH%;classes src\*.java

