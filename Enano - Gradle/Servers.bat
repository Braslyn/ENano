start java --enable-preview -jar ENano-server\build\libs\ENano-server-1.0-SNAPSHOT.jar
start java --enable-preview -jar ENano-Compiler\build\libs\ENano-Compiler-1.0-SNAPSHOT.jar
start cmd /k cd PrologServer && swipl ServerTranspilator.pl
exit