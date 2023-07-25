trigger AptosSuccess on Store_Aptos_Output__c (after update) {
    List<Id> recordsToDelete = new List<Id>();

    for (Store_Aptos_Output__c record : Trigger.new) {
        // Check if the status is "Success"
        if (record.Status__c == 'Success') {
            recordsToDelete.add(record.Id);
        }
    }

    if (!recordsToDelete.isEmpty()) {
        // Delete the records
        database.delete(recordsToDelete);
    }
}