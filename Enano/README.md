Authors:
		Enrique Mendez Cabezas 117390080
		Braslyn Rodriguez Ramirez 402420750
		Philippe Gairaud Quesada 117290193

Para compilar el proyecto con maven , seguimos los siguientes pasos:

1- En la misma carpeta donde se encuentra el pom.xml
se ejecuta el comando "mvn clean verify" para crear los
respectivos .jar

2- Ocupamos 2 terminales para iniciar el servidor estatico
y el servidor de servicios

3- En una de las 2 terminales y permaneciendo en la carpeta donde 
se encuentra el pom.xml ingrese el comando de 
"java --enable-preview -jar target\ENano-jar-with-dependencies.jar"
con el objetivo de iniciar el servidor estatico ENano.

4- En una de las 2 terminales y permaneciendo en la carpeta donde 
se encuentra el pom.xml ingrese el comando de 
"java --enable-preview -jar target\ENCompiler-jar-with-dependencies.jar"
con el objetivo de iniciar el servidor de Servicios ECompiler.

5-Con ambos servidores activos estamos listos para utilizar la pagina web:
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

--------------------------------------------------------------------------------------------
Cambiar de puerto para ambos servidores:
1- Situado en la carpeta donde se encuentra el pom.xml ir a web/properties/.

2- Abra el archivo .properties de Enano o Ecompile con su editor de texto favorito.

3- Edite el puerto que prefiere asignar, cuide que el formato sea "port=pppp" , donde pppp
son los posibles puertos a asignar.

-Caso Default:
 Si no se encuentran los archivos de properties para Enano y Ecompile se asumen
 los puertos 8080 y 9090 respectivamente.
