@RestResource(UrlMapping='/simplr/getHistoricalCases')
global with sharing class SimplrGetHistoricalCasesAction {
    global class SimplrGetHistoricalCasesResponse {
        global List<Case> historicalCaseObjects;
    }

    @HttpPost
    global static SimplrGetHistoricalCasesResponse action(String suppliedEmail) {
        RestResponse res = RestContext.response;
        List<Case> historicalCasesObjList = SimplrQueries.getCasesBySuppliedEmail(suppliedEmail);
        SimplrGetHistoricalCasesResponse response = new SimplrGetHistoricalCasesResponse();
        response.historicalCaseObjects = historicalCasesObjList;
        
        return response;
    }
}