@isTest
public class VContactToPersonAccountProcessTest {
    @isTest
    static void testProcess() {
        VContactTriggerHandler.CONVERT_TO_PERSON_ACCOUNT_EXECUTED = true;

        Contact con = new Contact(FirstName = 'Test', LastName = 'Test');
        insert con;

        VContactToPersonAccountProcess p = new VContactToPersonAccountProcess(new List<Contact> { con });
        Test.startTest();
        System.enqueueJob(p);
        Test.stopTest();

        System.assertEquals(1, [select count() from Account where PersonContactId = :con.Id]);

    }
}