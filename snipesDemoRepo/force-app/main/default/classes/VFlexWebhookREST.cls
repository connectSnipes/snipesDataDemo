@RestResource(urlMapping='/flexwebhook')
global without sharing class VFlexWebhookREST {
    @HttpPost
    global static void doPost() {
        List<PutResponse> res = new List<PutResponse>();
        RestRequest restReq = RestContext.request;
        RestResponse restResp = RestContext.response;

        String req = restReq.requestBody.toString();
        System.debug(req);

        Map<String, Object> requestBodyObj = (Map<String, Object>)JSON.deserializeUntyped(req);

        VOrderService svc = new VOrderService();
        try {
            svc.lastRequest = req;
            svc.processOrders(new List<VOrder> { (VOrder)JSON.deserialize(JSON.serialize(((Map<String, Object>)requestBodyObj.get('data')).get('data')), VOrder.class) }, new OrderSuccessHandler(res), new OrderErrorHandler(res));
            restResp.statusCode = 200;
        } catch(Exception e) {
            System.debug(e.getStackTraceString());
            restResp.statusCode = 200;
            PutResponse pr = new PutResponse();
            pr.errorCode = e.getTypeName();
            pr.message = e.getMessage();
            res.add(pr);
        } finally {
            String strResponse = JSON.serialize(res, false);
            restResp.responseBody = Blob.valueOf(strResponse);

            svc.lastResponse = strResponse;

            svc.commitLogs();
        }
    }

    @TestVisible
    private class PutResponse {
        public String errorCode;
        public String message;
    }

    @TestVisible
    private class OrderErrorHandler implements IOrderErrorHandler {
        public List<PutResponse> putResp { get; private set; }

        public OrderErrorHandler(List<PutResponse> putResp) {
            this.putResp = putResp;
        }

        public void handleError(String errorCode, String message) {
            PutResponse pr = new PutResponse();
            pr.errorCode = errorCode;
            pr.message = message;

            putResp.add(pr);
        }
    }

    @TestVisible
    private class OrderSuccessHandler implements IOrderSuccessHandler {
        public List<PutResponse> putResp { get; private set; }

        public OrderSuccessHandler(List<PutResponse> putResp) {
            this.putResp = putResp;
        }

        public void handleSuccess(String orderNumber) {
            PutResponse pr = new PutResponse();
            pr.errorCode = null;
            pr.message = 'Success';

            putResp.add(pr);
        }
    }
}