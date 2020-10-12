/*
	Authors:
		Enrique Mendez Cabezas 117390080
		Braslyn Rodriguez Ramirez 402420750
		Philippe Gairaud Quesada 117290193
*/
package com.eif400.server;

import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.io.*;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.function.*;
import java.util.stream.*;
import java.util.Properties;

import fi.iki.elonen.NanoHTTPD;
import fi.iki.elonen.router.RouterNanoHTTPD;
import static fi.iki.elonen.NanoHTTPD.Response;

import static fi.iki.elonen.NanoHTTPD.MIME_PLAINTEXT;
import static fi.iki.elonen.NanoHTTPD.SOCKET_READ_TIMEOUT;

import fi.iki.elonen.router.RouterNanoHTTPD.DefaultHandler;
import fi.iki.elonen.router.RouterNanoHTTPD.IndexHandler;

import java.util.logging.Level; 
import java.util.logging.Logger;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

import java.util.Arrays;
import java.util.Locale;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;  
import javax.tools.*;

public class ENCompiler extends RouterNanoHTTPD {
    static int PORT = 9090;
	Logger logger = Logger.getLogger(ENCompiler.class.getName());
	
	public static class CompileHandler extends DefaultHandler{
		String text;
		@Override
        public String getText() {
            return text;
        }
		
        @Override
        public String getMimeType() {
            return "application/json";
        }
     
        @Override
        public Response.IStatus getStatus() {
            return Response.Status.OK;
        }
		
		@Override//Compila la clase de java
		public Response post(UriResource uriResource, Map<String, String> urlParams, IHTTPSession session){
			File file=null;
			Integer contentLength = Integer.parseInt(session.getHeaders().get( "content-length" ));
			byte[] buf = new byte[contentLength];
			try{
			session.getInputStream().read( buf, 0, contentLength );
			text=String.format("%s",new String(buf,StandardCharsets.UTF_8));
		}catch(Exception e){
			text="Fallo";
		}
		
		String name="file";
		
		try{
			//hay que encontrar el nombre de la clase
			
			Pattern pattern = Pattern.compile("class (\\w+)\\{", Pattern.DOTALL);
			Matcher matcher = pattern.matcher(text);
			if(matcher.find()){
				name = matcher.group(1);
			}
			
		//se crea el archivo y se escribe en él.
			file = new File(name+".java");
			if (file.createNewFile()) {
				FileWriter myWriter = new FileWriter(name+".java");
				myWriter.write(text);
				myWriter.close();
			} else {
				FileWriter myWriter = new FileWriter(name+".java");
				myWriter.write(text);
				myWriter.close();
			}
		}catch(Exception e){
			
		}
			//------------------------------------------------------------
		text="";
		JavaCompiler compiler = ToolProvider.getSystemJavaCompiler();
		DiagnosticCollector< JavaFileObject > diagsCollector = new DiagnosticCollector<>();
		Locale locale = null;
		Charset charset = null;
		String outdir = "classes";
		String optionsString = String.format("-d %s", outdir);
		 
		try {
			var fileManager = compiler.getStandardFileManager( diagsCollector, locale, charset );
			var sources = fileManager.getJavaFileObjectsFromFiles(Arrays.asList( file ) );
		 
			Writer writer = new PrintWriter(System.err);
			// Also check out compiler.isSupportedOption() if needed
		 
			Iterable<String> options = Arrays.asList(optionsString.split(" "));
			Iterable<String> annotations = null;
			var compileTask = compiler.getTask( writer, 
									  fileManager, 
									  diagsCollector, 
									  options, 
									  annotations, 
									  sources );
		compileTask.call();
		} catch(Exception e){
		  System.err.format("%s%n", e);
		  System.exit(-1);
		}
		// Report diagnostics - adaptados para retonar json
		text="";
		if (diagsCollector.getDiagnostics().size() == 0){
			text="*** No errors found ***";
			file.delete();
			//------------------------------------------------------------
			text=String.format("{\"result\":\"%s\"}",text);
            ByteArrayInputStream inp = new ByteArrayInputStream(text.getBytes());
			Response response = newFixedLengthResponse(getStatus(), getMimeType(), inp, text.getBytes().length);
			return response;
		}
		for( var d: diagsCollector.getDiagnostics() ) {
			long pos = d.getLineNumber();
			String location = pos >= 0 ? String.format("Line: %d", pos) : "Unavailable:";
			text+=String.format("%s %s \\n",
				location, 
				d.getMessage( locale.ENGLISH ).replaceAll("\n"," "));
		}	
			file.delete();
			//------------------------------------------------------------
			text=String.format("{\"result\":\"%s\"}",text);
            ByteArrayInputStream inp = new ByteArrayInputStream(text.getBytes());
			Response response = newFixedLengthResponse(getStatus(), getMimeType(), inp, text.getBytes().length);
			return response;
        }
	}
	
	public ENCompiler(int port) throws IOException {
        super(port);
        addMappings();
        start(SOCKET_READ_TIMEOUT, false);
        System.out.format("*** Compiler running on port %d ***%n", port);
    }
	
	@Override
    public void addMappings() {
        addRoute("/compile", CompileHandler.class);
    }
	
	
    List<String> ALLOWED_SITES= Arrays.asList("http://localhost:5231","same-site","same-origin");//actualizar la lista con el sitio correcto
	@Override
	public Response serve(IHTTPSession session){
		logger.log(Level.INFO, "Connection request from "+session.getRemoteIpAddress()+" to get "+session.getUri());
		String origin="*";
		/*boolean cors_allowed= request_header!=null && 
								"cors".equals(request_header.get("sec-fetch-mode"))&&
								ALLOWED_SITES.indexOf(request_header.get("sec-fetch-mode"))>=0
								&& (origin=request_header.get("origin"))!=null;
		Response response = super.serve(session);
		//if (cors_allowed){
			response.addHeader("Access-Control-Allow-Origin",origin);
		//}*/
		Response response = super.serve(session);
		response.addHeader("Access-Control-Allow-Origin",origin);
		return response;
	}
	
	
    public static void main(String[] args ) throws IOException {
		String PORT=null;
		try{
		InputStream inputStream= new FileInputStream(new File("./web/properties/Ecompiler.properties"));
		Properties prop = new Properties();
		prop.load(inputStream);
		PORT = prop.getProperty("port");
        }catch(Exception e){
			System.out.format("Archivo /properties/Ecompiler.properties %s",e.getMessage());
			
		}
		if(PORT==null)
			PORT="9090";
        new ENCompiler(Integer.parseInt(PORT));
    }
	
}