@isTest
public class SimplrLoadTest {
    private static final Account acc = new Account(name='test');
    private static final Contact conNew = new Contact(Lastname='testing');
    @testSetup static void setUp() {
        insert acc;
        insert conNew;
    }
    static testMethod void loadTest() {
        test.setMock(HttpCalloutMock.class, new SimplrWebhookHTTPMock());
        Test.startTest();
        List<Case> testList = new List<Case>();
        for (Integer i = 0; i < 200; i++) {
            Case thisCase = new Case(ContactId=conNew.id, AccountId=acc.Id, status='New', Origin='Email',  Type='Outfitter');
            testList.add(thisCase);
        }
        insert testList;
        Test.stopTest();
    }
    static testMethod void loadTestDifferentCaseAttributes() {
        test.setMock(HttpCalloutMock.class, new SimplrWebhookHTTPMock());
        Test.startTest();
        List<Case> testList = new List<Case>();
        List<String> statuses = new List<String>();
        statuses.add('New');
        statuses.add('Working');
        statuses.add('Transferred');
        List<String> origins = new List<String>();
        origins.add('Email');
        origins.add('Public Email');
        origins.add('Web');
        origins.add('Phone');
        for (Integer i = 0; i < 100; i++) {
            Integer randomNumber = Integer.valueof((Math.random() * 10));
            Integer statusIdx = Math.mod(randomNumber, statuses.size());
            Integer originsIdx = Math.mod(randomNumber, origins.size());
            Case thisCase = new Case(ContactId=conNew.id, AccountId=acc.Id, status=statuses[statusIdx], Origin=origins[originsIdx], Type='Outfitter');
            testList.add(thisCase);
        }
        insert testList;
        for (Case cse: testList) {
          Integer randomNumber = Integer.valueof((Math.random() * 10));
            Integer statusIdx = Math.mod(randomNumber, statuses.size());
            Integer originsIdx = Math.mod(randomNumber, origins.size());
            cse.Status = statuses[statusIdx];
            cse.Origin = origins[originsIdx];
        }
        update testList;
        Test.stopTest();
    }
}