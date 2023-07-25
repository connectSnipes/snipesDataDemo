@isTest
public class SimplrGetHistoricalCasesActionTest {
    static testMethod void getHistoricalCases() {
        Test.setMock(HttpCalloutMock.class, new SimplrWebhookHTTPMock());
        Contact conNew = new Contact(Lastname='Test Contact', email='testing@test.com');
        insert conNew;
        
        Account acc = new Account(name='Test Account');
        insert acc;
        Case c = new Case(ContactId=conNew.Id, AccountId=acc.Id, Status='New', Origin='Email', Priority = 'Medium', Subject='Testing', SuppliedEmail='testing@test.com');
        insert c;

        
        SimplrGetHistoricalCasesAction.SimplrGetHistoricalCasesResponse caseInfo = SimplrGetHistoricalCasesAction.action('testing@test.com');
        System.assertEquals(c.Id, caseInfo.historicalCaseObjects[0].Id);

    }
}