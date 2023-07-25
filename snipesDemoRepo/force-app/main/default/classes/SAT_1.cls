public class SAT_1 {
    
    public static void m1 ()
    {
        List<Account> reList = new List<Account>();
        reList = [select Id,Name from Account where Name ='Ram'];
        
        System.debug('Check 1'); 
       // System.debug(reList);         
    }
}