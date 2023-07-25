//Author -Yashas S K (yashas_sk@perfaware.com)
public class AptosErrorHandling implements Database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, Status__c,PayloadStatus__c, Order_Summary__r.Status FROM Store_Aptos_Output__c';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Store_Aptos_Output__c> scope) {
    List<OrderSummary> orderSummariesToUpdate = new List<OrderSummary>(); // Order Summary records to update
    List<Store_Aptos_Output__c>StatusToUpdate=new List<Store_Aptos_Output__c>();//Store Aptos records to update    
  
    for (Store_Aptos_Output__c sao : scope) {
         if(sao.Status__c == 'Failed' && sao.PayloadStatus__c == 'ReTrigger1'){
            sao.PayloadStatus__c = 'ReTrigger2';
            sao.Order_Summary__r.Status = 'Pending to Approved';
             StatusToUpdate.add(sao);
            
            orderSummariesToUpdate.add(sao.Order_Summary__r);
            
        }
         else if(sao.Status__c == 'Failed' && sao.PayloadStatus__c == 'ReTrigger2'){
           sao.PayloadStatus__c = 'ReTrigger3';
           sao.Order_Summary__r.Status = 'Pending to Approved';
             StatusToUpdate.add(sao);
           orderSummariesToUpdate.add(sao.Order_Summary__r);
         }
   
      
        else if(sao.Status__c == 'Failed' && sao.PayloadStatus__c == 'ReTrigger3'){
           sao.PayloadStatus__c = 'Manual Intervention Needed';
            sao.Order_Summary__r.Status = 'Pending to Approved';
            StatusToUpdate.add(sao);
            orderSummariesToUpdate.add(sao.Order_Summary__r);
        }
        
             else {
            sao.PayloadStatus__c = 'ReTrigger1';
            sao.Order_Summary__r.Status = 'Pending to Approved';
                 StatusToUpdate.add(sao);
            orderSummariesToUpdate.add(sao.Order_Summary__r);
                
        }
         
           
    }
    update StatusToUpdate;
    update orderSummariesToUpdate;
    
}
    
    public void finish(Database.BatchableContext bc) {
        // Perform any post-processing tasks if needed
    }
}