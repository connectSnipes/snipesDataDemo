public with sharing class VFlexOrderEventsController {
    @AuraEnabled
    public static List<VFlexOrderEvent> getEvents(String orderId) {
        VFlexOrderAPI api = new VFlexOrderAPI();

        if(Test.isRunningTest()) {
            api.accessToken = 'Test';
        }
        
        return api.getOrderEvents(orderId);
    }
}