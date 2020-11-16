Authors:
		Enrique Mendez Cabezas 117390080
		Braslyn Rodriguez Ramirez 402420750
		Philippe Gairaud Quesada 117290193

Para compilar el proyecto con maven , seguimos los siguientes pasos:

1- En la misma carpeta raiz donde se pueden ver los archivos de gradle
se ejecuta el comando "gradle clean build" para crear los
respectivos .jar

2- Ocupamos 3 terminales para iniciar el servidor estatico, el servidor de servicios
y una para el Server de prolog.

3- En una de las 2 terminales y permaneciendo en la carpeta donde 
se encuentra el archivo gradlew ingrese el comando de 
"java --enable-preview -jar ENano-server\build\libs\ENano-server-1.0-SNAPSHOT.jar"
con el objetivo de iniciar el servidor estatico ENano.

4- En una de las 2 terminales y permaneciendo en la carpeta donde 
se encuentra el archivo gradlew ingrese el comando de 
"java --enable-preview -jar ENano-Compiler\build\libs\ENano-Compiler-1.0-SNAPSHOT.jar"
con el objetivo de iniciar el servidor de Servicios ECompiler.

5- En una nueva terminal donde se encuentra el archivo gradlew ejecutar swipl PrologServer\ServerTrasnpilator.pl

6-Con ambos servidores activos estamos listos para utilizar la pagina web:
http://localhost:5231/ para el servidor estatico.

--------------------------------------------------------------------------------------------
URLs
Las siguientes urls corresponden al servidor estatico con puerto 8080 por defecto, pero
usualmente siendo el 5231, siendo pppp el posible puerto para la url.
http://localhost:pppp/ esta url esta destinada para traer la pagina web
http://localhost:pppp/info esta url tiene como objetivo pedir la informacion del about
La siguiente url corresponde al servidor de servicios , tanto por defecto y puerto de uso 
comun corresponde a 9090
http://localhost:pppp/compile 
La siguiente URL corresponde a los servidores que traen el calculo de alguna clase nano
http://localhost:pppp/evaluate 

http://localhost:pppp/transpile se encarga de transpilar Nano a Java 

--------------------------------------------------------------------------------------------
Cambiar de puerto para ambos servidores:
1- Situado en la carpeta donde se encuentra el pom.xml ir a web/properties/.

2- Abra el archivo .properties de Enano o Ecompile con su editor de texto favorito.

3- Edite el puerto que prefiere asignar, cuide que el formato sea "port=pppp" , donde pppp
son los posibles puertos a asignar.

-Caso Default:
 Si no se encuentran los archivos de properties para Enano , Ecompile , ServerTrasnpilator se asumen
 los puertos 8080 , 9090 y 3030 respectivamente.
