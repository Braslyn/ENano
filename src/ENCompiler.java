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

import java.util.Arrays;
import java.util.Locale;
import java.nio.charset.Charset;

import javax.tools.*;

public class ENCompiler extends RouterNanoHTTPD {
    static int PORT = 9090;
	
	
	public static class CompileHandler extends DefaultHandler{
		@Override
        public String getText() {
            return "";
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
			String text=String.format("%s ***%n",urlParams);
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
	
	
    List<String> ALLOWED_SITES= Arrays.asList("same-site","same-origin");
	@Override
	public Response serve(IHTTPSession session){
		var request_header = session.getHeaders();
		String origin="*";
		boolean cors_allowed= request_header!=null && 
								"cors".equals(request_header.get("sec-fetch-mode"))&&
								ALLOWED_SITES.indexOf(request_header.get("sec-fetch-mode"))>=0
								&& (origin=request_header.get("origin"))!=null;
		Response response = super.serve(session);
		if (cors_allowed){
			response.addHeader("Access-Control-Allow-Origin",origin);
		}		
		return response;
	}
    public static void main(String[] args ) throws IOException {
        PORT = args.length == 0 ? 9090 : Integer.parseInt(args[0]);
        new ENCompiler(PORT);
    }
	
}