public class SimplrWebhook {
    public static String buildWebhookJSON(String type, List<Object> triggerList) {
        String userId = UserInfo.getUserId();
        String orgId = UserInfo.getOrganizationId();
        String orgDomain = Url.getOrgDomainUrl().getHost();

        Map<String, Object> content = new Map<String, Object> {
            'userId' => userId,
            'orgId' => orgId,
            'orgDomain' => orgDomain,
            'type' => type,
            'data' => triggerList
        };
        return JSON.serialize(content);
    }

    @Future(Callout = true)
    public static void callout(String content) {
        Http http = new Http();

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Simplr_Credential');
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer {!$Credential.Password}');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(content);
        

        http.send(req);
    }
}