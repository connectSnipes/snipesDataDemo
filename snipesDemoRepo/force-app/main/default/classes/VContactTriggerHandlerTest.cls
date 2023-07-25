@isTest
public class VContactTriggerHandlerTest {
    @isTest
    static void testConversionToPersonAccount() {
        Contact con = new Contact(FirstName = 'Test', LastName = 'Test');

        Test.startTest();
        insert con;
        Test.stopTest();

        System.assertEquals(1, [select count() from Account where PersonContactId = :con.Id]);

    }
}