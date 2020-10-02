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
	
	
    record authors(int id,String name){
		public String toString(){
			return String.format("{\"ID\":%s,\"name\":\"%s\"}",id,name);
		}
    }
    record info(int nrc,int group, String version, String repository){
		public String toString(){
			return String.format("{\"NRC\":%s,\"group\":%s,\"version\":\"%s\",\"repository\":\"%s\"}",nrc,group,version,repository);
		}
	}
	public static class AuthorsHandler extends DefaultHandler{
		List<authors> auths= Arrays.asList(new authors(402420750,"Braslyn Rodriguez Ramirez"),
		new authors(117290193,"Philippe Gairaud Quesada"),new authors(117390080,"Enrique Mendez Cabezas"));
		@Override
        public String getText() {
            return auths.stream().map(authors::toString).collect(Collectors.joining(",", "[", "]"));
        }
        @Override
        public String getMimeType() {
            return "application/json";
        }
     
        @Override
        public Response.IStatus getStatus() {
            return Response.Status.OK;
        }
		
		@Override//devuelve el JSON con La info de Authors
		public Response post(UriResource uriResource, Map<String, String> urlParams, IHTTPSession session) {
            String text = getText();
            ByteArrayInputStream inp = new ByteArrayInputStream(text.getBytes());
			Response response=newFixedLengthResponse(getStatus(), getMimeType(), inp, text.getBytes().length);
			response.addHeader("Access-Control-Allow-Origin","*");
            return response;
        }
    }
    public static class InfoHandler extends DefaultHandler{
		info data = new info(50058,6,"1.1","https://github.com/Braslyn/ENano");
		
		@Override
        public String getText() {
            return data.toString();
        }
        @Override
        public String getMimeType() {
            return "application/json";
        }
     
        @Override
        public Response.IStatus getStatus() {
            return Response.Status.OK;
        }
		
		@Override//devuelve el JSON con la info
		public Response post(UriResource uriResource, Map<String, String> urlParams, IHTTPSession session) {
            String text = getText();
            ByteArrayInputStream inp = new ByteArrayInputStream(text.getBytes());
			Response response = newFixedLengthResponse(getStatus(), getMimeType(), inp, text.getBytes().length);
            response.addHeader("Access-Control-Allow-Origin","*");
			return response;
        }
	}
	
    public static class PageHandler extends RouterNanoHTTPD.StaticPageHandler {
		final String root="./web";
		Logger logger = Logger.getLogger(ENano.class.getName()); 
        @Override
        public NanoHTTPD.Response get(RouterNanoHTTPD.UriResource uriResource, Map<String, String> urlParams, NanoHTTPD.IHTTPSession session) {
			logger.log(Level.INFO, "Connection request from "+session.getRemoteIpAddress()+" to get "+session.getUri());
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
        addRoute("/authors", AuthorsHandler.class);
        addRoute("/info", InfoHandler.class);
		addRoute("/(?!\s).*", PageHandler.class);
    }
    
    public static void main(String[] args ) throws IOException {
        PORT = args.length == 0 ? 5231 : Integer.parseInt(args[0]);
        new ENano(PORT);
    }
}