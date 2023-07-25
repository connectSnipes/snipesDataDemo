@isTest
public class VSocialPostTriggerHandlerTest {
    @isTest
    static void testSocialPostTrigger() {
        Account acc = new Account(FirstName = 'Test',
            LastName = 'Test',
            IgnoreSocialPosts__c = true);
        insert acc;

        SocialPersona p = new SocialPersona(
            ParentId = acc.Id,
            Provider = 'Twitter',
            Name = 'Test Test'
        );

        insert p;

        SocialPost sp = new SocialPost(
            PersonaId = p.Id,
            Content = 'Test',
            Name = 'Test',
            WhoId = acc.Id
        );

        insert sp;

        acc.IgnoreSocialPosts__c = false;
        update acc;

        p.IsBlacklisted = true;
        update p;

        sp = new SocialPost(
            PersonaId = p.Id,
            Content = 'Test',
            Name = 'Test',
            WhoId = acc.Id
        );

        insert sp;

        p.IsBlacklisted = false;
        update p;

        sp = new SocialPost(
            PersonaId = p.Id,
            Content = '#TestContextOnly',
            Name = 'Test',
            WhoId = acc.Id
        );

        insert sp;
    }
}