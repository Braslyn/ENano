import java.util.function.UnaryOperator;
 public class Simple { 
 final double PI = 3.14;  
 String name = "Brazza";  
 final UnaryOperator<Integer> func = x -> x*x;  
 final UnaryOperator<Integer> abs = x -> ( x>=0 )? x : x;  
 static int fact(int n) { return ( n==0 )? 1 : n*fact(n-1); }
   public static void main(String args[]){ 
 System.out.println(fact(5));
   }}