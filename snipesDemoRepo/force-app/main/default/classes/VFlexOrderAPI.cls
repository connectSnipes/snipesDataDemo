public class VFlexOrderAPI {
    public static final String CLIENT_ID = VSettings.settings.SnipesClientId__c;
    public static final String CLIENT_SECRET = VSettings.settings.SnipesClientSecret__c;
    public static final String BRAND_ID = VSettings.settings.SnipesBrandId__c;

    public static final String TOKEN_ENDPOINT = VSettings.settings.SnipesTokenEndpoint__c;
    public static final String API_ENDPOINT = VSettings.settings.SnipesAPIEndpoint__c + '/' + BRAND_ID;

    @TestVisible
    public String accessToken { get; set; }

    public List<VFlexOrderEvent> getOrderEvents(String orderId) {
        List<VFlexOrderEvent> res = new List<VFlexOrderEvent>();

        authenticate();

        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setMethod('GET');
        req.setEndpoint(API_ENDPOINT + '/order-events?orderId=' + EncodingUtil.urlEncode(orderId, 'UTF-8'));
    
        Http h = new Http();
        HttpResponse resp = h.send(req);

        if(resp.getStatusCode() == 200) {
            System.debug(resp.getBody());
            res = (List<VFlexOrderEvent>)JSON.deserialize(resp.getBody(), List<VFlexOrderEvent>.class);
        }

        return res;
    }

    public void deleteWebhook(String webhookId) {
        authenticate();

        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setMethod('DELETE');
        req.setEndpoint(API_ENDPOINT + '/webhooks/' + webhookId);
    
        Http h = new Http();
        HttpResponse resp = h.send(req);

        System.debug(resp.getStatusCode());
        System.debug(resp.getBody());
    }

    public void getWebhooks() {
        authenticate();

        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setMethod('GET');
        req.setEndpoint(API_ENDPOINT + '/webhooks');
    
        Http h = new Http();
        HttpResponse resp = h.send(req);

        System.debug(resp.getStatusCode());
        System.debug(resp.getBody());
    }

    public void createWebhook(String url, Boolean enabled) {
        createWebhook(url, enabled, '["ORDER_EVENTS.OMS.ORDER_CONFIRMED","ORDER_EVENTS.OMS.ORDER_SHIPPED","ORDER_EVENTS.OMS.ORDER_CANCELLED","ORDER_EVENTS.OMS.ORDER_FTC_DELAYED","ORDER_EVENTS.OMS.ORDER_RETURN_RECEIVED","ORDER_EVENTS.OMS.ORDER_RETURN_REQUESTED","ORDER_EVENTS.OMS.ORDER_BACK_ORDERED","ORDER_EVENTS.OMS.ORDER_COMPLETED","ORDER_EVENTS.OMS.ORDER_CREDIT_ISSUED","ORDER_EVENTS.OMS.ORDER_PICKUP_READY","ORDER_EVENTS.OMS.ORDER_PICKUP_COMPLETED","ORDER_EVENTS.OMS.ORDER_PICKUP_REMINDED","ORDER_EVENTS.OMS.ORDER_PICKUP_SHOPPER_ARRIVED","ORDER_EVENTS.OMS.ORDER_PICKUP_SHOPPER_CONFIRMED","ORDER_EVENTS.OMS.ORDER_PICKUP_SHOPPER_IN_TRANSIT","ORDER_EVENTS.OMS.ORDER_PICKUP_DELAYED","ORDER_EVENTS.OMS.ORDER_SHIPMENT_UPDATED","ORDER_EVENTS.OMS.UNKNOWN","ORDER_EVENTS.TRACKING.SHIPMENT_PRE_TRANSIT","ORDER_EVENTS.TRACKING.SHIPMENT_IN_TRANSIT","ORDER_EVENTS.TRACKING.SHIPMENT_OUT_FOR_DELIVERY","ORDER_EVENTS.TRACKING.SHIPMENT_DELIVERED","ORDER_EVENTS.TRACKING.SHIPMENT_AVAILABLE_FOR_PICKUP","ORDER_EVENTS.TRACKING.SHIPMENT_RETURNED_TO_SENDER","ORDER_EVENTS.TRACKING.SHIPMENT_FAILURE"]');
    }

    public void createWebhook(String url, Boolean enabled, String events) {
        authenticate();

        Map<String, Object> body = new Map<String, Object> {
            'endpoint' => url,
            'events' => (List<Object>)JSON.deserializeUntyped(events),
            'enabled' => enabled
        };

        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setMethod('POST');
        req.setEndpoint(API_ENDPOINT + '/webhooks');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(JSON.serialize(body));
    
        Http h = new Http();
        HttpResponse resp = h.send(req);

        System.debug(resp.getStatusCode());
        System.debug(resp.getBody());
    }

    public void sendShipmentNotification(VFlexShipmentNotification notif) {
        authenticate();

        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Content-Type', 'application/json');
        req.setMethod('POST');
        req.setEndpoint(API_ENDPOINT + '/shipment-notification');

        req.setBody(JSON.serialize(notif));

        Http h = new Http();
        HttpResponse resp = h.send(req);

        if(resp.getStatusCode() != 200) {
            Map<String, Object> resultObj = (Map<String, Object>)JSON.deserializeUntyped(resp.getBody());

            throw new VFlexOrderAPIException((String)resultObj.get('message'));
        }
    }

    @TestVisible
    private void authenticate() {
        if(accessToken == null) {
            HttpRequest req = new HttpRequest();

            Map<String, String> urlParams = new Map<String, String>();
            urlParams.put('grant_type', 'client_credentials');
            urlParams.put('client_id', CLIENT_ID);
            urlParams.put('scope', 'flexengage.gateway/order.events.create');

            req.setHeader('Accept', 'application/json');
            req.setHeader('Authorization', 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(CLIENT_ID + ':' + CLIENT_SECRET)));
            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            req.setMethod('POST');
            req.setEndpoint(TOKEN_ENDPOINT);
            req.setBody(urlEncode(urlParams));

            Http h = new Http();
            HttpResponse resp = h.send(req);
            Map<String, Object> responseObj = (Map<String, Object>)JSON.deserializeUntyped(resp.getBody());
            if(!responseObj.containsKey('access_token') && !Test.isRunningTest()) {
                throw new VFlexOrderAPIException('Unable to get access token');
            }

            accessToken = (String)responseObj.get('access_token');
        }
    }

    private String urlEncode(Map<String, String> urlParams) {
        List<String> res = new List<String>();

        for(String key : urlParams.keySet()) {
            String opt = key + '=' + EncodingUtil.urlEncode(urlParams.get(key), 'UTF-8');
            res.add(opt);
        }

        return String.join(res, '&');
    }

    public class VFlexOrderAPIException extends Exception {}
}