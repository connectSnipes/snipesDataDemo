public class HttpCalloutClass {
    public static void performCalloutAndUpdateStatus() {
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://api.abc.com/endpoint');//Desired Endpoint of Mulesoft should be given here
        request.setMethod('GET');
        
        HttpResponse response = new HttpResponse();
        try {
            Http http = new Http();
            response = http.send(request);
            
            // Parse the JSON response and get the status attribute
            if (response.getStatusCode() == 200) {
                JSONParser parser = JSON.createParser(response.getBody());
                while (parser.nextToken() != null) {
                    //we are getting only the 'Failed' Records from the Json Response
                    if (parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getText() == 'Failed') {
                        // Move to the value of the 'status' attribute
                        parser.nextToken();
                        String status = parser.getText();
                        
                        // Create a list of Store_Aptos_Output__c records
                        List<Store_Aptos_Output__c> aptosOutputsToUpdate = new List<Store_Aptos_Output__c>();
                        // Add records to aptosOutputsToUpdate list
                        
                        // Update the 'status' field in each Store_Aptos_Output__c record
                        
                        for (Store_Aptos_Output__c aptosOutput : aptosOutputsToUpdate) {
                            aptosOutput.status__c = 'Failed';
                        }
                        
                        update aptosOutputsToUpdate;
                        return;
                    }
                }
            }
        } catch (Exception e) {
            System.debug('Exception occurred: ' + e.getMessage());
        }
    }
}
 //"HttpCalloutClass.performCallout();"this will be the method for calling this callout in the batch apex  get the response