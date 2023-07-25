@isTest
public class VCaseMergeBatchTest {
    @isTest
    static void testMerge() {
        Account acc = new Account(
            FirstName = 'Test',
            LastName = 'Test'
        );

        Account acc2 = new Account(
            FirstName = 'Test2',
            LastName = 'Test2'
        );

        insert new List<Account> { acc, acc2 };

        insert new List<Case> {
            new Case(
                AccountId = acc.Id,
                Subject = 'Test\'s',
                OwnerId = '00G4S000000pYyr',
                Description = 'Test'
            ),
            new Case(
                AccountId = acc.Id,
                Subject = 'Test\'s',
                OwnerId = '00G4S000000pYz1',
                Description = 'Test'
            ),
            new Case(
                AccountId = acc.Id,
                Subject = 'Test2',
                OwnerId = '00G4S000000pYz1',
                Description = 'Test'
            ),
            new Case(
                AccountId = acc.Id,
                Subject = 'Test',
                OwnerId = '00G4S000000pYz1',
                Status = 'Closed',
                Description = 'Test'
            ),
            new Case(
                AccountId = acc.Id,
                Subject = 'Test',
                Description = 'Test'
            ),
            new Case(
                AccountId = acc2.Id,
                Subject = 'Test',
                OwnerId = '00G4S000000pYz1',
                Description = 'Test'
            )
        };

        VCaseMergeBatch b = new VCaseMergeBatch();
        Test.startTest();
        Database.executeBatch(b);
        Test.stopTest();

        System.assertEquals(4, [select count() from Case]);
    }
}