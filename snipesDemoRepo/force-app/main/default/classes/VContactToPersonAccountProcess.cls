public class VContactToPersonAccountProcess implements Queueable {
    public List<Contact> contactsToProcess = new List<Contact>();

    public VContactToPersonAccountProcess(List<Contact> contactsToProcess) {
        this.contactsToProcess = contactsToProcess;
    }

    public void execute(QueueableContext QC) {
        VAccountTriggerHandler.DISABLE_CORDIAL_UPDATE = true;
        contactsToProcess = [select Id, FirstName, LastName, OwnerId from Contact where Id in :contactsToProcess];
        
        List<Account> accountsToInsert = new List<Account>();

        for(Contact con : contactsToProcess) {
            accountsToInsert.add(new Account(
                OwnerId = con.OwnerId,
                Name = con.FirstName + ' ' + con.LastName,
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business_Account').getRecordTypeId()));
        }

        insert accountsToInsert;

        List<Contact> contactsToUpdate = new List<Contact>();
        for(Integer i = 0; i < contactsToProcess.size(); i++) {
            Account acc = accountsToInsert[i];
            Contact con = contactsToProcess[i];

            contactsToUpdate.add(new Contact(Id = con.Id, AccountId = acc.Id));
        }

        update contactsToUpdate;

        List<Account> accountsToUpdate = new List<Account>();
        for(Account acc : accountsToInsert) {
            accountsToUpdate.add(new Account(Id = acc.Id, RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId()));
        }

        update accountsToUpdate;
    }
}