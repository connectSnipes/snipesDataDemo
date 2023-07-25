trigger AptosTest on Store_Aptos_Output__c (after delete) {
    // Get the deleted records
    List<Store_Aptos_Output__c> deletedRecords = Trigger.new;
    System.debug('Number of deleted Store_Aptos_Output__c records: ' + deletedRecords.size());
    
    // Collect the related Order_Summary__c record IDs
    Set<Id> orderSummaryIds = new Set<Id>();
    for (Store_Aptos_Output__c deletedRecord : deletedRecords) {
        orderSummaryIds.add(deletedRecord.Order_Summary__c);
    }
    
    System.debug('Number of related Order_Summary__c record IDs: ' + orderSummaryIds.size());
    
    // Query and update the related Order_Summary__c records
    List<OrderSummary> orderSummariesToUpdate = [SELECT Id, Status FROM OrderSummary WHERE Id IN :orderSummaryIds];
    System.debug('Number of OrderSummary records to update: ' + orderSummariesToUpdate.size());
    
    for (OrderSummary orderSummary : orderSummariesToUpdate) {
        orderSummary.Status = 'Pending to Approved'; 
    }
    
    // Perform the updates
    if (!orderSummariesToUpdate.isEmpty()) {
        System.debug('Updating OrderSummary records...');
        database.update(orderSummariesToUpdate);
    }
}