@isTest
public class VCaseTriggerHandlerTest {
    @isTest
    static void testSendSurvey() {
        VAccountTriggerHandler.DISABLE_CORDIAL_UPDATE = true;
        Account acc = new Account(FirstName = 'Test',
            LastName = 'Test',
            PersonEmail = 'test@test.com');

        insert acc;

        acc = [select Id, PersonContactId from Account where Id = :acc.Id];

        Case cse = new Case(
            Subject = 'Test',
            ContactId = acc.PersonContactId
        );

        insert cse;

        cse.Survey_Sent_Date__c = Date.today();
        update cse;
    }
    
    @isTest
    static void testMatchAmazonCase() {
        VAccountTriggerHandler.DISABLE_CORDIAL_UPDATE = true;
        Account acc = new Account(FirstName = 'Test',
            LastName = 'Test',
            PersonEmail = 'test@test.com',
            Amazon_Connect_Phone__c = '5555555555');

        insert acc;

        acc = [select Id, PersonContactId from Account where Id = :acc.Id];

        Case cse = new Case(
            Subject = 'Test',
            ContactId = acc.PersonContactId,
            AccountId = acc.Id,
            Type = 'Callback Request',
            Amazon_Connect_Phone__c = '+15555555555',
            OwnerId = VSettings.settings.CallbackQueueID__c
        );

        insert cse;
    }
    
    @isTest
    static void deleteDuplicateAmazonCase() {
        VAccountTriggerHandler.DISABLE_CORDIAL_UPDATE = true;
        Account acc = new Account(FirstName = 'Test',
            LastName = 'Test',
            PersonEmail = 'test@test.com',
            Amazon_Connect_Phone__c = '5555555555');

        insert acc;

        acc = [select Id, PersonContactId from Account where Id = :acc.Id];

        Case cse = new Case(
            Subject = 'Test',
            ContactId = acc.PersonContactId,
            AccountId = acc.Id,
            Type = 'Callback Request',
            Amazon_Connect_Phone__c = '+15555555555',
            OwnerId = VSettings.settings.CallbackQueueID__c
        );

        insert cse;
        cse = cse.clone(false, true);
        insert cse;
    }
}