@isTest
public class SimplrAddTagsToCaseActionTest {
    private static final Account acc = new Account(name='test');
    private static final Contact conNew = new Contact(Lastname='testing');
    @testSetup static void setUp() {
        insert acc;
        insert conNew;
    }
    
    static testMethod void testAddTagsToCase() {
        Test.setMock(HttpCalloutMock.class, new SimplrWebhookHTTPMock());
        Map<String, Schema.SObjectField>  fieldMap = Schema.getGlobalDescribe().get( 'Case' ).getDescribe().fields.getMap();
        Schema.SObjectField field = null;
        Schema.SObjectField dependentField = null;
        
        
        for (String key: fieldMap.keySet()) {
            if (fieldMap.get(key).getDescribe().isDependentPicklist()) {
                dependentField = fieldMap.get(key);
                field = fieldMap.get(key).getDescribe().getController();
                break;
            }
        }
        String fieldName = field.getDescribe().getName();
        String subTagFieldName = dependentField.getDescribe().getName();
        
        Case c = new Case(ContactId=conNew.Id, AccountId=acc.Id, Status='New', Origin='Phone');
        insert c;
        
        String fields = field.getDescribe().getName();
        if(dependentField != null) {
            fields += ', ' + dependentField.getDescribe().getName();
        }

        String query = 'Select Id, CaseNumber, ' + fields + ' from Case where Id = \'' + c.Id + '\' limit 1';

        List<Case> cases = database.query(query);
		System.debug(fieldName);
        System.debug(subTagFieldName);
        
        
        List<SimplrGetCaseTagsAction.SimplrCaseTag> tags = SimplrGetCaseTagsAction.action(fieldName, subTagFieldName);
        String updateTag = null;
        String updateSubTag = null;
        for (SimplrGetCaseTagsAction.SimplrCaseTag tag: tags) {
            if (tag.subTags != null && tag.subTags.size() > 0) {
                updateTag = tag.tag;
                updateSubTag = tag.subTags[0].tag;
            }
        }

        SimplrAddTagsToCaseAction.action(c.Id, fieldName, updateTag, subTagFieldName, updateSubTag);

        cases = database.query(query);
		System.debug('case reason' + cases[0]);
		System.assertEquals(cases[0].get(fieldName), updateTag);
        System.assertEquals(cases[0].get(subTagFieldName),  updateSubTag);
    }
    
     static testMethod void testAddTagsToCaseNoCaseID() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
    
        req.requestURI = 'https://testy.test'; 
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
        SimplrAddTagsToCaseAction.action(null, null, null, null, null);
        System.assertEquals(400, res.statusCode);         
     }
    
     static testMethod void testAddTagsToCaseBadCaseID() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
    
        req.requestURI = 'https://testy.test'; 
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
        Test.setMock(HttpCalloutMock.class, new SimplrWebhookHTTPMock());
        Map<String, Schema.SObjectField>  fieldMap = Schema.getGlobalDescribe().get( 'Case' ).getDescribe().fields.getMap();
        Schema.SObjectField field = null;
        Schema.SObjectField dependentField = null;
        
        
        for (String key: fieldMap.keySet()) {
            if (fieldMap.get(key).getDescribe().isDependentPicklist()) {
                dependentField = fieldMap.get(key);
                field = fieldMap.get(key).getDescribe().getController();
                break;
            }
        }
        String fieldName = field.getDescribe().getName();
        String subTagFieldName = dependentField.getDescribe().getName();
         
        Case c = new Case(ContactId=conNew.Id, AccountId=acc.Id, Status='New', Origin='Phone');
        insert c;
        
        List<SimplrGetCaseTagsAction.SimplrCaseTag> tags = SimplrGetCaseTagsAction.action(fieldName, subTagFieldName);
        String updateTag = null;
        String updateSubTag = null;
        for (SimplrGetCaseTagsAction.SimplrCaseTag tag: tags) {
            if (tag.subTags != null && tag.subTags.size() > 0) {
                updateTag = tag.tag;
                updateSubTag = tag.subTags[0].tag;
            }
        }

        SimplrAddTagsToCaseAction.action('12345', fieldName, updateTag, subTagFieldName, updateSubTag);
		System.assertEquals(400, res.statusCode);

    }
    
    static testMethod void testAddTagsToCaseCaseDoesntExist() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
    
        req.requestURI = 'https://testy.test'; 
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
        Test.setMock(HttpCalloutMock.class, new SimplrWebhookHTTPMock());
        Map<String, Schema.SObjectField>  fieldMap = Schema.getGlobalDescribe().get( 'Case' ).getDescribe().fields.getMap();
        Schema.SObjectField field = null;
        Schema.SObjectField dependentField = null;
        
        
        for (String key: fieldMap.keySet()) {
            if (fieldMap.get(key).getDescribe().isDependentPicklist()) {
                dependentField = fieldMap.get(key);
                field = fieldMap.get(key).getDescribe().getController();
                break;
            }
        }
        String fieldName = field.getDescribe().getName();
        String subTagFieldName = dependentField.getDescribe().getName();
        
        Case c = new Case(ContactId=conNew.Id, AccountId=acc.Id, Status='New', Origin='Phone');
        insert c;
        String caseID = c.Id;
        delete c;
        
        List<SimplrGetCaseTagsAction.SimplrCaseTag> tags = SimplrGetCaseTagsAction.action(fieldName, subTagFieldName);
        String updateTag = null;
        String updateSubTag = null;
        for (SimplrGetCaseTagsAction.SimplrCaseTag tag: tags) {
            if (tag.subTags != null && tag.subTags.size() > 0) {
                updateTag = tag.tag;
                updateSubTag = tag.subTags[0].tag;
            }
        }

        c = SimplrAddTagsToCaseAction.action(caseId, fieldName, updateTag, subTagFieldName, updateSubTag);
		System.assertEquals(null, c);

    }
}