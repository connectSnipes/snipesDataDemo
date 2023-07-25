public class HttpCalloutExample {
    public void makeCallout() {
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://api.example.com/endpoint');
        request.setMethod('GET');
        // Set other request headers, parameters, and body if needed

        Http http = new Http();
        HttpResponse response = http.send(request);

        // Process the response
        if (response.getStatusCode() == 200) {
            // Successful callout
            String responseBody = response.getBody();
            // Process the response body
        } else {
            // Error Handling
            String errorMessage = 'HTTP callout failed with status code: ' + response.getStatusCode();
           
        }
    }
}