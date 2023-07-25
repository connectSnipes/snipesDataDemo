@isTest
public class VAPILogCleanupTest {
    @isTest
    static void testBatch() {
        APILog__c lg = new APILog__c();
        insert lg;

        VAPILogCleanupSchedule s = new VAPILogCleanupSchedule();

        Test.startTest();
        s.execute(null);
        Test.stopTest();

        System.assertEquals(0, [select count() from APILog__c]);
    }
}