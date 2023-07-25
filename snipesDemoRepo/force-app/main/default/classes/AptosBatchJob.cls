public class AptosBatchJob implements Database.Batchable<sObject> {
    List<Store_Aptos_Output__c> apt;

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String suc = 'Success';
        String query = 'SELECT Id, Name, Order_Summary__r.Status FROM Store_Aptos_Output__c WHERE Status__c = :suc';
        return Database.getQueryLocator(query);
    }

   public void execute(Database.BatchableContext bc, List<Store_Aptos_Output__c> scope) {
    List<Id> scopeIds = new List<Id>();
    if (scope.size() > 0) {
        Set<Id> orderSummaryIds = new Set<Id>();
        for (Store_Aptos_Output__c sao : scope) {
            scopeIds.add(sao.Id);
            orderSummaryIds.add(sao.Order_Summary__c);
        }
        apt = [SELECT Id, Name, Order_Summary__r.Status
               FROM Store_Aptos_Output__c
               WHERE Order_Summary__c IN :orderSummaryIds];
        
        for (Store_Aptos_Output__c sao : scope) {
            for (Store_Aptos_Output__c aptRecord : apt) {
                if (aptRecord.Order_Summary__c == sao.Order_Summary__c) {
                    aptRecord.Order_Summary__r.Status = 'Pending to Approved';
                }
            }
        }
    }
    update apt;
       
    Database.delete(scopeIds);
}


    public void finish(Database.BatchableContext bc) {
        // Perform any post-processing tasks if needed
    }
}