@isTest
public with sharing class VDuplicateMergeBatchTest {
    @isTest
    static void testBatch() {
        Account acc = new Account(FirstName = 'Test', LastName = 'Test', PersonEmail = 'test@test.com');
        insert acc;

        Account acc2 = new Account(FirstName = 'Test', LastName = 'Test', Phone = '555-555-5555');
        insert acc2;

        VDuplicateMergeBatch b = new VDuplicateMergeBatch();
        Database.executeBatch(b);
    }
}