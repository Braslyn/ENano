import java.io.*;
import java.util.*;
import fi.iki.elonen.NanoHTTPD;
import static fi.iki.elonen.NanoHTTPD.MIME_HTML;
import static fi.iki.elonen.NanoHTTPD.Response;

/**
 * Author : Braslyn Rodriguez Ramirez -- Braslynrrr999@gmail.com
 */
 

public class ENano extends NanoHTTPD
{
	//static final int HTTP_OK=200;
	public ENano(int port) throws IOException{
		super(port);
		start(NanoHTTPD.SOCKET_READ_TIMEOUT, false);
	}

    @Override
    public Response serve(IHTTPSession session) {
		String msg = "<html><body><h1>Hello server</h1>\n";
		Map<String, String> parms = session.getParms();
		if (parms.get("username") == null) {
			msg += "<form action='?' method='get'>\n  <p>Your name: <input type='text' name='username'></p>\n" + "</form>\n";
		} else {
			msg += "<p>Hello, " + parms.get("username") + "!</p>";
		}
		return newFixedLengthResponse(msg + "</body></html>\n");
    }


	public static void main( String[] args )
	{
		int port= Integer
		try
		{
			new ENano(5741);
			
		}
		catch( IOException ioe )
		{
			System.err.println( "Couldn't start server:\n" + ioe );
			System.exit( -1 );
		}
		System.out.println( "Listening on port "+args[0]+". Hit Enter to stop.\n" );
		try { System.in.read(); } catch( Throwable t ) {};
	}
}