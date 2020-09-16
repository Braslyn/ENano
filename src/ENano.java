import java.io.*;
import java.util.*;
import fi.iki.elonen.NanoHTTPD;
import static fi.iki.elonen.NanoHTTPD.MIME_HTML;
import static fi.iki.elonen.NanoHTTPD.Response;
import java.util.logging.Level; 
import java.util.logging.Logger;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

/**
 * Author : Braslyn Rodriguez Ramirez -- Braslynrrr999@gmail.com
 */
 

public class ENano extends NanoHTTPD{
	
	
	final String MIME_CSS="text/css";
	final String MIME_JS="text/javascript";
	final String MIME_ICO="image/x-icon";
	
	Logger logger = Logger.getLogger(ENano.class.getName()); 
	
	public ENano(int port) throws IOException{
		super(port);
		start(NanoHTTPD.SOCKET_READ_TIMEOUT, false);
	}
	
	private final List<String> ALLOWED_SITES= Arrays.asList("same-site","same-origin");
    @Override
    public Response serve(IHTTPSession session){
		logger.log(Level.INFO, "Connection request from "+session.getRemoteIpAddress()+" to get "+session.getUri());
		StringBuilder contentBuilder = new StringBuilder();
		String origin="*";
		/*var request_header= session.getHeaders();
		
		boolean cors_allowed= request_header!=null && 
								"cors".equals(request_header.get("sec-fetch-mode"))&&
								ALLOWED_SITES.indexOf(request_header.get("sec-fetch-mode"))>=0
								&& (origin=request_header.get("origin"))!=null;
		Response response= super.serve(session);
		if (cors_allowed){
			response.addHeader("Access-Control-Allow-Origin",origin);
		}
		*/
		//response.addHeader("Content-Disposition: attachment; filename=", "./web/index.html");
		Response response;
		switch(session.getUri()){
			case "/":
				response = makeResponse("./web/index.html",MIME_HTML);
				break;
			case "/css/form.css":
				response = makeResponse("./web/css/form.css",MIME_CSS);
				break;
			case "/js/Main.js":
				response = makeResponse("./web/js/Main.js",MIME_JS);
				break;
			case "/favicon.ico":
				response = makeResponse("./web/favicon.ico",MIME_ICO);
				break;
			default:
			response = makeResponse("./web/index.html",MIME_HTML);
		}
		response.addHeader("Access-Control-Allow-Origin",origin);
		return response;
    }
	private static Response makeResponse(String route,String type){
		 try {
            Path path = Paths.get(route);
            Response resp = newFixedLengthResponse(
                    Response.Status.OK,
                    type,
                    Files.newInputStream(path),
                    Files.size(path)
            );
            return resp;
        } catch (final Exception ex) { 
            ex.printStackTrace();
            return newFixedLengthResponse(Response.Status.NOT_FOUND, MIME_PLAINTEXT, "ERROR");
        }
	}
	
	public static void main(String[] args){
		int port= args.length>0? Integer.parseInt(args[1]):5231;
		try{
			new ENano(port);
		}
		catch( IOException ioe )
		{
			System.err.println( "Couldn't start server:\n" + ioe);
			System.exit( -1 );
		}
		System.out.println( "Listening on port "+port+". Hit cntr+c twice to stop.\n" );
		try { System.in.read(); } catch( Throwable t ) {};
	}
}