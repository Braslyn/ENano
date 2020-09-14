import java.io.*;
import java.util.*;
import fi.iki.elonen.NanoHTTPD;
import static fi.iki.elonen.NanoHTTPD.MIME_HTML;
import static fi.iki.elonen.NanoHTTPD.Response;
import java.util.logging.Level; 
import java.util.logging.Logger; 

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
		String content;
		logger.log(Level.INFO, "Connection to "+session.getRemoteIpAddress());
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
		try {
			BufferedReader in = new BufferedReader(new FileReader("./web/index.html"));
			String str;
			while ((str = in.readLine()) != null) {
				contentBuilder.append(str);
			}
			in.close();
			content= contentBuilder.toString(); 
		}catch (IOException e) {
		    content= e.getMessage();
		}
		
		Response response= newFixedLengthResponse(content);
		response.addHeader("Access-Control-Allow-Origin",origin);
		return response;
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