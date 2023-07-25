@isTest
public class VDuplicateServiceJJTest {
    @isTest
    static void testProcessContacts() {
        Account acc = new Account(FirstName = 'Test', LastName = 'Test', PersonEmail = 'test@test.com');
        insert acc;

        Account acc2 = new Account(FirstName = 'Test', LastName = 'Test', Phone = '555-555-5555');
        insert acc2;

        Database.DmlOptions opts = new Database.DmlOptions();
        opts.DuplicateRuleHeader.AllowSave = true;

        List<Contact> conList = new List<Contact> { new Contact(FirstName = 'Test', LastName = 'Test', Email = 'test@test.com', Phone = '555-555-5555') };
        Database.insert(conList, opts);

        VDuplicateSErviceJJ svc = new VDuplicateServiceJJ();
        System.assertNotEquals(null, svc.processContacts(conList));
        System.assertEquals(2, [select count() from Contact]);
    }
}