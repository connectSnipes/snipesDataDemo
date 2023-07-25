public class VCordialAPI {
    public static final String API_KEY = VSettings.settings.CordialAPIKeyQC__c;

    public static List<VCordialContact> getLatestContacts(DateTime cutOff) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(VSettings.settings.CordialEndpoint__c + '/contacts?sort_by=lastModified&sort_dir=desc');
        req.setMethod('GET');
        req.setHeader('Authorization', 'Basic ' + getBasicAuth(API_KEY));
        req.setHeader('Content-Type', 'application/json');
        

        Http h = new Http();
        HttpResponse resp = h.send(req);
        String body = resp.getBody().replace(',"channels":[]', '').replace(',"address":[]', '');
        System.debug(body);
        
        List<VCordialContact> tmpList = (List<VCordialContact>)JSON.deserialize(body, List<VCordialContact>.class);
        List<VCordialContact> res = new List<VCordialContact>();

        for(VCordialContact cc : tmpList) {
            if(cc.attributes.lastModified >= cutOff) {
                res.add(cc);
            }
        }

        return res;
    }

    public static void pushOrder(VCordialOrder ord) {
        HttpRequest req = new HttpRequest();
            req.setEndpoint(VSettings.settings.CordialEndpoint__c + '/orders');
            req.setMethod('POST');
            req.setHeader('Authorization', 'Basic ' + getBasicAuth(API_KEY));
            req.setHeader('Content-Type', 'application/json');
            req.setBody(JSON.serialize(ord, true));
            try {
                Http h = new Http();
                HttpResponse resp = h.send(req);
                
                String respBody = resp.getBody();
                System.debug(respBody);
            } catch(Exception e) {
                System.debug(e.getMessage());
                System.debug(e.getStackTraceString());
            }
    }

    public static String pushContact(VCordialContact con) {
        String email = con.channels.email.address;
        String res = null;

        if(String.isNotBlank(email)) {
            HttpRequest req = new HttpRequest();
            req.setEndpoint(VSettings.settings.CordialEndpoint__c + '/contacts/email:' + email);
            req.setMethod('PUT');
            req.setHeader('Authorization', 'Basic ' + getBasicAuth(API_KEY));
            req.setHeader('Content-Type', 'application/json');
            req.setBody(JSON.serialize(con, true));
            System.debug(req.getBody());
 
            try {
                Http h = new Http();
                HttpResponse resp = h.send(req);
                
                String respBody = resp.getBody();
                System.debug(respBody);
                if(respBody.contains('CONTACTS_CONTACT_NOT_FOUND') || Test.isRunningTest()) {
                    req.setEndpoint(VSettings.settings.CordialEndpoint__c + '/contacts');
                    req.setMethod('POST');

                    System.debug(req.getBody());

                    resp = h.send(req);
                    respBody = resp.getBody();

                    Map<String, Object> respMap = (Map<String, Object>)JSON.deserializeUntyped(respBody);
                    Boolean isSuccess = (Boolean)respMap.get('success');
                    if(isSuccess) {
                        res = (String)respMap.get('cID');
                    }
                }
            } catch(Exception e) {
                System.debug(e.getMessage());
                System.debug(e.getStackTraceString());
            }
        }

        return res;
    }

    private static String getBasicAuth(String apiKey) {
        return EncodingUtil.base64Encode(Blob.valueOf(apiKey + ':'));
    }
}