import java.util.function.UnaryOperator;
import java.util.Arrays;
import java.util.List;
 public class chiky {
       
public static final int x = 66;  
public static final UnaryOperator<Integer> abs = x -> ( x>=0 )? x : -x;  
public static int fact(int n) { return ( n==0 )? 1 : n*fact(n-1); }
   public static void main(String args[]){    
 System.out.println(String.format("abs(%d)=%d",-x,abs.apply(x))); 
 System.out.println(String.format("fact(%d)=%d",5,fact(5))); 
 final int x = 999;  
 final List<Integer>  list = Arrays.asList(1,-2,3,x+x);  
 System.out.println(list);
   }
   }