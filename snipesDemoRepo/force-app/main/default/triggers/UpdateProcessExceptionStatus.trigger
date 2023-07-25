trigger UpdateProcessExceptionStatus on Store_Aptos_Output__c (after delete) {
    // Collect the IDs of deleted StoreAptosOutput records with status 'Success'
    Set<Id> successRecordIds = new Set<Id>();
    for (Store_Aptos_Output__c deletedRecord : Trigger.old) {
        if (deletedRecord.Status__c == 'Success') {
            successRecordIds.add(deletedRecord.Id);
        }
    }

    // Retrieve the related Process Exception records associated with the deleted StoreAptosOutput records
    List<ProcessException> processExceptionList = [select id from ProcessException where OrderSummary.OrderNumber IN :successRecordIds];

    // Update the Status of Process Exception records to 'Resolved'
    List<ProcessException> processExceptionToUpdate = new List<ProcessException>();
    for (ProcessException exc : processExceptionList) {
        exc.Status = 'Resolved';
        processExceptionToUpdate.add(exc);
    }

    // Perform the update
    if (!processExceptionToUpdate.isEmpty()) {
        try {
            update processExceptionToUpdate;
        } catch (DmlException ex) {
            System.debug('An error occurred while updating Process Exception records: ' + ex.getMessage());
            // Handle the exception here if needed
        }
    }
}