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
    public Response serve(IHTTPSession session){
		/*try{
			
		var file=new File("./web/index.html");
        var fis = new FileInputStream(file);
		String sfile="";
		}catch(...){
			sfile="Hola";
		}
		sfile=newFixedLengthResponse(getFileContent(fis,sfile));
		return sfile;
		*/
		
		 StringBuilder contentBuilder = new StringBuilder();
			try {
				BufferedReader in = new BufferedReader(new FileReader("./web/index.html"));
				String str;
				while ((str = in.readLine()) != null) {
					contentBuilder.append(str);
				}
				in.close();
			} catch (IOException e) {
			}
		String content = contentBuilder.toString(); 
			return newFixedLengthResponse(content);
    }


	public static String getFileContent(FileInputStream fis,String encoding ) throws IOException{
		  try( BufferedReader br = new BufferedReader( new InputStreamReader(fis, encoding ))){
		  StringBuilder sb = new StringBuilder();
		  String line;
			while(( line = br.readLine()) != null ) {
				sb.append( line );
				sb.append( '\n' );
			}
		    return sb.toString();
	    }
	}
	
	public static void main( String[] args ){
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