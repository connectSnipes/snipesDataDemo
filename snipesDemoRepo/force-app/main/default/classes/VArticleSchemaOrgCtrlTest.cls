@isTest
public class VArticleSchemaOrgCtrlTest {
    @isTest
    static void testController() {
        Knowledge__kav ka = new Knowledge__kav(
            Title = 'Test',
            UrlName = 'Test',
            Answer__c = 'Test'
        );

        insert ka;

        System.assertNotEquals(null, VArticleSchemaOrgCtrl.getSchemaOrgData(ka.Id));
    }
}