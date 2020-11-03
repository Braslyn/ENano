/*
	Authors:
		Enrique Mendez Cabezas 117390080
		Braslyn Rodriguez Ramirez 402420750
		Philippe Gairaud Quesada 117290193
*/
package com.eif400.server;

import java.io.IOException;
import java.io.*;
import java.util.*;
import java.util.function.*;
import java.util.stream.*;
import java.util.Properties;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

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



public class ENano extends RouterNanoHTTPD {
    static int PORT = 5231;
	Logger logger = Logger.getLogger(ENano.class.getName()); 
    public static class InfoHandler extends DefaultHandler{
		final Pattern Getline = Pattern.compile("(\\w+): ([a-zA-Z| -.:\\/|[0-9]+]*)");
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
		private String Json(Matcher matcher){
			matcher.find();
			return String.format("\"%s\":\"%s\"",matcher.group(1),matcher.group(2));	
		}
			
		@Override//devuelve el JSON con la info
		public Response get(UriResource uriResource, Map<String, String> urlParams, IHTTPSession session) {
            //Lee del archivo
			try{
				var Data= Files.lines(Paths.get("./web/Data_Json/Info.txt")).collect(Collectors.toList());
				text = Data.stream().reduce("{",(x,y)-> x+Json(Getline.matcher(y))+",");
				Data = Files.lines(Paths.get("./web/Data_Json/Authors.txt")).collect(Collectors.toList());
				Data = Data.stream().map(line -> Getline.matcher(line) ).map( match -> Json(match) ).collect(Collectors.toList());
				String team=String.format("\"team\":{%s,\"members\":[",Data.get(0));
				
				for(int i=1;i<Data.size();i++){
					switch((i-1)%3){
					case 0:
						team+="{"+Data.get(i)+",";
						break;
					case 1:
						team+=Data.get(i)+",";
						break;
					case 2:
						team+= i+1==Data.size()? Data.get(i)+"}":Data.get(i)+"},";
						break;
					}
				}
				team+="]}";
				text+=text.format(team);
			}catch(Exception ex){
				text="{\"result\":\""+ex.getMessage()+"\"";
			}
			text+="}";
			//Posible Cliente de DB
            ByteArrayInputStream inp = new ByteArrayInputStream(text.getBytes());
			Response response = newFixedLengthResponse(getStatus(), getMimeType(), inp, text.getBytes().length);
			return response;
        }
	}
	
    public static class PageHandler extends RouterNanoHTTPD.StaticPageHandler {
		final String root="./web";
        @Override
        public NanoHTTPD.Response get(RouterNanoHTTPD.UriResource uriResource, Map<String, String> urlParams, NanoHTTPD.IHTTPSession session) {
			StringBuilder contentBuilder = new StringBuilder();
			String route=root+session.getUri();
			Response response=makeResponse(route);
			return response;
        }
		
		
		private static Response makeResponse(String route){
		try {
			if(route.charAt(route.length()-1)=='/')
				route+="index.html";
            Path path = Paths.get(route);
            Response resp = newFixedLengthResponse(
                    Response.Status.OK,
                    getMimeTypeForFile(route),
                    Files.newInputStream(path),
                    Files.size(path)
            );
				return resp;
			} catch (final Exception ex) { 
				ex.printStackTrace();
				return newFixedLengthResponse(Response.Status.NOT_FOUND, MIME_PLAINTEXT, "ERROR");
			}
		}
		
    }
	
	
    public ENano(int port) throws IOException {
        super(port);
        addMappings();
        start(SOCKET_READ_TIMEOUT, false);
        System.out.format("*** Server running on port %d ***%n", port);
    }
	
	

    @Override
    public void addMappings() {
        addRoute("/info", InfoHandler.class);
		addRoute("/(?!\s).*", PageHandler.class);
    }
	
    List<String> ALLOWED_SITES= Arrays.asList("same-site","same-origin");
	@Override
	public Response serve(IHTTPSession session){
		var request_header = session.getHeaders();
		logger.log(Level.INFO, "Connection request from "+session.getRemoteIpAddress()+" to get "+session.getUri());
		String origin="*";
		boolean cors_allowed= request_header!=null && 
								"cors".equals(request_header.get("sec-fetch-mode"))&&
								ALLOWED_SITES.indexOf(request_header.get("sec-fetch-mode"))>=0
								&& (origin=request_header.get("origin"))!=null;
		Response response= super.serve(session);
		if (cors_allowed){
			response.addHeader("Access-Control-Allow-Origin",origin);
		}		
		return response;
	}
	
    public static void main(String[] args ) throws IOException {
		String PORT=null;
		try{
        InputStream inputStream= new FileInputStream(new File("./web/properties/Enano.properties"));
		Properties prop = new Properties();
		prop.load(inputStream);
		PORT = prop.getProperty("port");
		}catch(Exception e){
			System.out.format("Archivo /properties/Enano.properties %s",e.getMessage());
		}
		if(PORT==null)
			PORT="8080";
        new ENano(Integer.parseInt(PORT));
    }
}