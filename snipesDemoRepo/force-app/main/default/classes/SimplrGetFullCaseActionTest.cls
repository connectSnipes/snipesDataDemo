@isTest
public class SimplrGetFullCaseActionTest {
    static testMethod void testGetFullCaseAction() {
        Test.setMock(HttpCalloutMock.class, new SimplrWebhookHTTPMock());
        Contact conNew = new Contact(Lastname='Test Contact');
        insert conNew;
        
        Account acc = new Account(name='Test Account');
        insert acc;
        
        Case c = new Case(ContactId=conNew.Id, AccountId=acc.Id, Status='New', Origin='Phone');
        insert c;
        
        
        EmailMessage email = new EmailMessage();
        
        email.fromName = 'bob';
        email.ToAddress = 'test@test.test';
        email.subject = 'test';
        email.TextBody = 'test';
        email.htmlBody = '<div>test</div>';
        email.ParentId = c.Id; 
        insert email;
        
        SimplrGetFullCaseAction.SimplrGetFullCaseResponse response = SimplrGetFullCaseAction.action(c.id);
        System.assertEquals(c.id, response.caseObject.Id);
        System.assertEquals(email.Id, response.emailMessages[0].Id);
    }
    
     static testMethod void testGetFullCaseActionCaseDoesntExist() {
        Test.setMock(HttpCalloutMock.class, new SimplrWebhookHTTPMock());
		RestContext.response = new RestResponse();
        
        SimplrGetFullCaseAction.action('12345');
		System.assertEquals(500, RestContext.response.statusCode);
    }
}