import java.util.function.UnaryOperator;
import java.util.Arrays;
import java.util.List;
 public class juanito3 {
    
public static final double PI = 3.14 ; 
public static String name = "Brazza" ; 
public static final UnaryOperator<Integer> func = x -> x*x ; 
public static final UnaryOperator<Integer> abs = x -> ( x>=0 )? x : x ; 
public static List<Integer>  L  ; 
public static int fact(int n) { return ( n==0 )? 1 : n*fact(n-1); };
   public static void main(String args[]){  
 int k = 10 ; 
 System.out.println(fact(k));
      }
   }