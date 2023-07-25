@RestResource(UrlMapping='/simplr/addTagsToCase')
global with sharing class SimplrAddTagsToCaseAction {

    @HttpPost
    global static Case action(String caseId, String tagField, String tag, String subTagField, String subTag) {
   		RestResponse res = RestContext.response;
        try {
            if (caseId == null || tagField == null || tag == null) {
               throw new SimplrException('Missing required properties caseId: ' + caseId + ', tagField: ' + tagField + ', tag: ' + tag, 400);
            }
    
            String fields = tagField;
            if(subTagField != null) {
                fields += ', ' + subTagField;
            }
            String query = 'Select Id, CaseNumber, ' + fields + ' from Case where Id = \'' + caseId + '\' limit 1';
            List<Case> cases = database.query(query);

            Case c = null;
            
            if (cases != null && !cases.isEmpty()) {
                c = cases[0];
                c.put(tagField, tag);
                if (subTagField != null && subTag != null) {
                    c.put(subTagField, subTag);
                }
                update c;
            } else {
                throw new SimplrException('Unable to locate case to tag', 400);
            }
            	cases = database.query(query);
            if (!cases.isEmpty()) {
                c = cases[0];
            }
            String updatedTag = (String) c.get(tagField);
    
    
            if(updatedTag != tag) {
                throw new SimplrException('Unable to update tag', 500);
            }
            String updatedSubTag = null;
            if (subTagField != null) {
                updatedSubTag = (String) c.get(subTagField);
                if (updatedSubTag != subTag) {
                    throw new SimplrException('Unable to update subtag', 500);
                }
            }
            return c;
        } catch (SimplrException e) {
            System.debug(e.getMessage());
            SimplrUtil.setErrorResponse(res, e.getMessage(), e.statusCode !=null ? e.statusCode:500);
            return null;
        } catch (Exception e) {
            System.debug(e.getMessage());
            SimplrUtil.setErrorResponse(res, e.getMessage(), 400);
            return null;
        } 
    }
}