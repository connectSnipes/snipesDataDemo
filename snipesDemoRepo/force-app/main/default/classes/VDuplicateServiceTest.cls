@isTest
public class VDuplicateServiceTest {
    @isTest
    static void testProcessContacts() {
        Account acc = new Account(FirstName = 'Test', LastName = 'Test', PersonEmail = 'test@test.com');
        insert acc;

        Account acc2 = new Account(FirstName = 'Test', LastName = 'Test', Phone = '555-555-5555');
        insert acc2;

        VDuplicateSErvice svc = new VDuplicateService();
        System.assertNotEquals(null, svc.processContacts(new List<Contact> { new Contact(FirstName = 'Test', LastName = 'Test', Email = 'test@test.com', Phone = '555-555-5555')}));
    }
}