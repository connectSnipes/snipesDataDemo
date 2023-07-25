@isTest
public class SimplrGetCaseTagsActionTest {
    static testMethod void testGetTagsWithDependantField() {
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

        if (dependentField != null) {
            List<PicklistEntry> picklist = field.getDescribe().getPicklistValues();
            List<PicklistEntry> dependentPicklist = dependentField.getDescribe().getPicklistValues();

            List<SimplrGetCaseTagsAction.SimplrCaseTag> tags = SimplrGetCaseTagsAction.action('' + field.getDescribe().getName(), '' + dependentField.getDescribe().getName());
			
            for (PicklistEntry entry: picklist) {
                Boolean foundTag = false;
            	Boolean foundSubtag = false;
                for(SimplrGetCaseTagsAction.SimplrCaseTag tag: tags) {
                    if (tag.tag == entry.getValue()) {
                        foundTag = true;
                        if (tag.subTags != null) {
                            for (PicklistEntry depEntry: dependentPicklist) {
                                 for (SimplrGetCaseTagsAction.SimplrCaseTag subTag: tag.subTags) {
                                     if (subTag.tag == depEntry.getValue()) {
                                         foundSubtag = true;
                                         break;
                                     } 
                                 }
                             }
                        } else {
                            foundSubtag = true;
                        }
                       break;
                    } 	
                }
                System.assert(foundTag && foundSubtag);
            }
        }
    }
    
    static testMethod void testGetTagsWithNoDependantField() {
        Map<String, Schema.SObjectField>  fieldMap = Schema.getGlobalDescribe().get( 'Case' ).getDescribe().fields.getMap();
        Schema.SObjectField field = null;
        
        
        for (String key: fieldMap.keySet()) {
            if ('' + fieldMap.get(key).getDescribe().getType() == 'PICKLIST') {
                field = fieldMap.get(key).getDescribe().getController();
                break;
            }
        }

        if (field != null) {
            List<PicklistEntry> picklist = field.getDescribe().getPicklistValues();

            List<SimplrGetCaseTagsAction.SimplrCaseTag> tags = SimplrGetCaseTagsAction.action('' + field.getDescribe().getName(), null);

            System.assertEquals(picklist.size(), tags.size());
            
            for (PicklistEntry entry: picklist) {
                Boolean foundTag = false;
                for(SimplrGetCaseTagsAction.SimplrCaseTag tag: tags) {
                    if (tag.tag == entry.getValue()) {
                        foundTag = true;
                       break;
                    } 	
                }
                System.assert(foundTag);
            }
        }
    }
}