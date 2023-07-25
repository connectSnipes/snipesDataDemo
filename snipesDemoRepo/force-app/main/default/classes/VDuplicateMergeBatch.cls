public class VDuplicateMergeBatch implements Database.Batchable<sObject> {
    public static List<String> FIELDS = new List<String>();

    static {
        Map<String, Schema.SObjectField> contactFields = Schema.SObjectType.Contact.fields.getMap();

        for(Schema.SObjectField contactField : contactFields.values()) {
            Schema.DescribeFieldResult dsr = contactField.getDescribe();

            if(dsr.isUpdateable()) {
                if(dsr.getName() != 'Name') {
                    FIELDS.add(dsr.getName());
                }
            }
        }
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator('select Id, {0} from Contact where Account.Brand_Origin__c != \'Jimmy Jazz\' and Account.IsPersonAccount = true'.replace('{0}', String.join(FIELDS, ',')));
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<Contact> conList = (List<Contact>)scope;

        VDuplicateServiceJJ svc = new VDuplicateServiceJJ();
        svc.processContacts(conList);
    }

    public void finish(Database.BatchableContext BC) {

    }
}