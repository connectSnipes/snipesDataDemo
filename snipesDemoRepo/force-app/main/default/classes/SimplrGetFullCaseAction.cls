@RestResource(UrlMapping='/simplr/getfullcase')
global with sharing class SimplrGetFullCaseAction {
    global class SimplrGetFullCaseResponse {
        global Case caseObject;
        global List<EmailMessage> emailMessages;
        global List<CaseFeed> caseFeedTextPosts;
    }

    @HttpPost
    global static SimplrGetFullCaseResponse action(String caseId) {
        RestResponse res = RestContext.response;
        try {

            SimplrGetFullCaseResponse response = new SimplrGetFullCaseResponse();
            response.caseObject = SimplrQueries.getCaseById(caseId);
            response.emailMessages = SimplrQueries.getAllEmailMessagesByCaseId(caseId);
            response.caseFeedTextPosts =SimplrQueries.getCaseFeedTextPostsByCaseId(caseId);
    
            return response;
        } catch (Exception e) {
            System.debug(e.getStackTraceString());
            SimplrUtil.setErrorResponse(res, e.getMessage(), 500);
            return null;
        }
    }
}