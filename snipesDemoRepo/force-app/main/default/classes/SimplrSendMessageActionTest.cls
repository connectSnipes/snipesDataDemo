@isTest
public class SimplrSendMessageActionTest {
    static testMethod void testAction() {
        Test.setMock(HttpCalloutMock.class, new SimplrWebhookHTTPMock());
        Contact conNew = new Contact(Lastname='Test Contact', Email='simplr@xyz.org');
        insert conNew;
        
        Account acc = new Account(name='Test Account');
        insert acc;
        
        Case c = new Case(ContactId=conNew.Id, AccountId=acc.Id, Status='New', Origin='Email', SuppliedEmail='test@abc.org');
        insert c;
        
        EmailMessage e = new EmailMessage();
        e.FromAddress = 'test@abc.org';
        e.Incoming = True;
        e.ToAddress= 'simplr@xyz.org';
        e.Subject = 'Test email';
        e.HtmlBody = 'Test email body';
        e.ParentId = c.Id; 
        insert e;
        
        
        EmailMessage email = SimplrSendMessageAction.action(c.Id, '<div>Hello, World!</div>', 'hello world');
        System.assertEquals(c.Id, email.parentId);
        System.assertEquals('simplr@xyz.org', email.ToAddress);
        
        // signature gets auto-appended from salesforce configuration
        System.assertEquals(true, email.textBody.contains('hello world'));
    }
    
    static testMethod void testActionServiceAddressNotFound() {
        Test.setMock(HttpCalloutMock.class, new SimplrWebhookHTTPMock());
        RestContext.response = new RestResponse();
        Contact conNew = new Contact(Lastname='Test Contact');
        insert conNew;
        
        Account acc = new Account(name='Test Account');
        insert acc;
        
        Case c = new Case(ContactId=conNew.Id, AccountId=acc.Id, Status='New', Origin='Email', SuppliedEmail='test@abc.org');
        insert c;
        
        

       	SimplrSendMessageAction.action(c.Id, '<div>Hello, World!</div>', 'hello world');
		System.assertEquals(400, RestContext.response.statusCode);

    }
    
    static testMethod void testActionNoSuppliedEmail() {
        Test.setMock(HttpCalloutMock.class, new SimplrWebhookHTTPMock());
        RestContext.response = new RestResponse();
        Contact conNew = new Contact(Lastname='Test Contact');
        insert conNew;
        
        Account acc = new Account(name='Test Account');
        insert acc;
        
        Case c = new Case(ContactId=conNew.Id, AccountId=acc.Id, Status='New', Origin='Email');
        insert c;
        
        EmailMessage e = new EmailMessage();
        e.FromAddress = 'simplr@abc.org';
        e.Incoming = True;
        e.ToAddress= 'simplr@xyz.org';
        e.Subject = 'Test email';
        e.HtmlBody = 'Test email body';
        e.ParentId = c.Id; 
        insert e;
        
		SimplrSendMessageAction.action(c.Id, '<div>Hello, World!</div>', 'hello world');
		System.assertEquals(400, RestContext.response.statusCode);
                
    }
    
    static testMethod void testActionNoCaseID() {
        Test.setMock(HttpCalloutMock.class, new SimplrWebhookHTTPMock());
        RestContext.response = new RestResponse();
        
		SimplrSendMessageAction.action(null, '<div>Hello, World!</div>', 'hello world');
		System.assertEquals(400, RestContext.response.statusCode);
                
    }
}