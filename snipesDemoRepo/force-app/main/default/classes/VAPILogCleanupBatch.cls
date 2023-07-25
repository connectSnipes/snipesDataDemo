public class VAPILogCleanupBatch implements Database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext BC) {
        Date cutOff = Date.today().addDays(VSettings.settings.APILogRetention__c.intValue()*-1);
        return Database.getQueryLocator([select Id from APILog__c where DAY_ONLY(CreatedDate) <= :cutOff]);
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        delete scope;
    }

    public void finish(Database.BatchableContext BC) {}
}