@isTest
global class SimplrWebhookHTTPMock implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{}');
        response.setStatusCode(200);
        return response; 
    }
}