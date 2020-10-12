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

-------------------------------------------------------------------------------
Cambiar de puerto para ambos servidores:
1- Situado en la carpeta donde se encuentra el pom.xml ir a web/properties/.

2- Abra el archivo .properties de Enano o Ecompile con su editor de texto favorito.

3- Edite el puerto que prefiere asignar, cuide que el formato sea "port=pppp" , donde pppp
son los posibles puerto a asignar.

-Caso Default:
 Si no se encuentran los archivos de properties para Enano y Ecompile se asumen
 los puertos 8080 y 9090 respectivamente.
