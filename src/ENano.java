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
	
	Logger logger = Logger.getLogger(ENano.class.getName()); 
	
	public ENano(int port) throws IOException{
		super(port);
		start(NanoHTTPD.SOCKET_READ_TIMEOUT, false);
	}
	
	private final List<String> ALLOWED_SITES= Arrays.asList("same-site","same-origin");
    @Override
    public Response serve(IHTTPSession session){
		logger.log(Level.INFO, "Connection request from "+session.getRemoteIpAddress()+"-> "+session.getUri());
		StringBuilder contentBuilder = new StringBuilder();
		String origin="none";
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
				response = newFixedLengthResponse(filetoString("./web/index.html"));
				break;
			case "/css/form.css":
				response = newFixedLengthResponse(filetoString("./web/css/form.css"));
				break;
			case "/js/Main.js":
				response = newFixedLengthResponse(filetoString("./web/js/Main.js"));
				break;
			default:
			response = newFixedLengthResponse(filetoString("./web/index.html"));
		}
		response.addHeader("Access-Control-Allow-Origin",origin);
		return response;
    }
	private static Response makeresponse(String route){
		 try {
            Path path = Paths.get(route);
            final Response resp = newFixedLengthResponse(
                    Response.Status.OK,
                    "text/plain",
                    Files.newInputStream(path),
                    Files.size(path)
            );
            resp.addHeader("Content-Disposition", "attachment; filename=\"+"route"+\"");
            return resp;
        } catch (final Exception ex) { // TODO: Error handling is bad
            ex.printStackTrace();
            return newFixedLengthResponse(Response.Status.NOT_FOUND, MIME_PLAINTEXT, "ERROR");
        }
	}
	
	private static String filetoString(String route){
		StringBuilder contentBuilder = new StringBuilder();
		String content;
		try {
			BufferedReader in = new BufferedReader(new FileReader(route));
			String str;
			while ((str = in.readLine()) != null) {
				contentBuilder.append(str);
			}
			in.close();
			content= contentBuilder.toString(); 
		}catch (IOException e) {
		    content= e.getMessage();
		}
		return content;
	}

	public static void main( String[] args ){
		int port= args.length>0? Integer.parseInt(args[1]):5231;
		try{
			new ENano(port);
		}
		catch( IOException ioe )
		{
			System.err.println( "Couldn't start server:\n" + ioe );
			System.exit( -1 );
		}
		System.out.println( "Listening on port "+port+". Hit Enter to stop.\n" );
		try { System.in.read(); } catch( Throwable t ) {};
	}
}