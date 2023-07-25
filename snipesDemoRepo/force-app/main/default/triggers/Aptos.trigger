trigger Aptos on Store_Aptos_Output__c (after update, after insert) {
    List<Id> toBeDeleted = new List<Id>();

    if (Trigger.isUpdate || Trigger.isInsert) {
        for (Store_Aptos_Output__c apt : Trigger.New) {
            if (apt.Status__c == 'Success') {
                toBeDeleted.add(apt.Id);
                System.debug('Record ID: ' + apt.Id);
            }
        }
    }

    // Delete the records
    if (!toBeDeleted.isEmpty()) {
        Database.delete(toBeDeleted);
        System.debug('Deleted');
    } else {
        System.debug('No records to delete.');
    }
}