import java.io.*;
import java.util.*;
import fi.iki.elonen.NanoHTTPD;
import static fi.iki.elonen.NanoHTTPD.Response;
import java.util.logging.Level; 
import java.util.logging.Logger;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

/**
 * Author : 
 		Enrique Mendez Cabezas 117390080
		Braslyn Rodriguez Ramirez 402420750
		Philippe Gairaud Quesada 117290193
 */

public class ENano extends NanoHTTPD{
	
	final String root="./web";
	Logger logger = Logger.getLogger(ENano.class.getName()); 
	
	public ENano(int port) throws IOException{
		super(port);
		start(NanoHTTPD.SOCKET_READ_TIMEOUT, false);
	}
	
	//private final List<String> ALLOWED_SITES= Arrays.asList("same-site","same-origin");
    @Override
    public Response serve(IHTTPSession session){
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