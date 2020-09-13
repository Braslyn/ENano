@echo off
set PORT=%1
if "%PORT%"=="" set PORT=3000
echo Using port=%PORT%
echo Enter halt. for leaving Prolog (don't forget the .)
swipl src\Prolog\server.pl %PORT%

