//author - Hemant Kumar Patel(hemant_patel@perfaware.com)
@RestResource(urlMapping='/PostFoRequests/*')
global class GetFoRequestPayloads {
	@HttpPost
    global static void getRequestPayloads(){
        RestRequest req = RestContext.request;
        //String headers = JSON.serialize(req.headers);
       // Map<String,Object> headerMap = (Map<String,Object>)JSON.deserializeUntyped(headers);
        //for(String str:headerMap.keySet()){
        //    System.debug(str+' : '+headerMap.get(str));
       // }
        String requestBody = req.requestBody.toString();
        Map<String,Object> mapp = (Map<String,Object>)JSON.deserializeUntyped(requestBody);
        String Authorization = 'Bearer 00D55000000Vxha!ARIAQGtvQZhVgV.75deIJ8ZjD.mifu8P0KeeD8AC9YSbIWrwcYIeTNmPaqlRpED_g3e.pOVF_K0_zdAWoF5UQQWWJwcvFCRO';
        String host ='https://snipesusa--devsfcc.sandbox.my.salesforce.com';
        HttpRequest httpReq = new HttpRequest();
        httpReq.setMethod('POST');
        httpReq.setHeader('Authorization', Authorization);
        httpReq.setHeader('Content-Type', 'application/json');
        Http http = new Http();
        HttpResponse response;
        String httpBody;
        //FO creation starts
        Object createPayload = mapp.get('create');
        if(createPayload != null){
        	httpReq.setEndpoint(host+'/services/data/v57.0/commerce/fulfillment/fulfillment-orders');
        	httpBody = JSON.serialize(createPayload);
        	httpReq.setBody(httpBody);
        	//response = http.send(httpReq); //--uncomment later
        	//System.debug(response.getStatus()); //-- uncomment later
        }
        //FO creation ends
        
        //FO cancellation starts
        Object cancelPayload = mapp.get('cancel');
        if(cancelPayload != null){
            String cancePayloadString = JSON.serialize(cancelPayload);
        	Map<String,Object> cancelPayloadMap = (Map<String,Object>)JSON.deserializeUntyped(cancePayloadString);
        	List<Object> foLineItems = (List<Object>)cancelPayloadMap.get('fulfillmentOrderLineItemsToCancel');
        	String foLineId ;
        	if(foLineItems.size() > 0){
            	for(Object o:foLineItems){
                	String oString = JSON.serialize(o);
            		Map<String,Object> oMap = (Map<String,Object>)JSON.deserializeUntyped(oString);
                	foLineId = (String)oMap.get('fulfillmentOrderLineItemId');
                	System.debug(foLineId);
                	break;
        		}
        }
        List<fulfillmentOrderLineItem> relatedFulfillmentOrder ;
        if(foLineId != null){
            relatedFulfillmentOrder = [SELECT id,fulfillmentOrder.Id from fulfillmentOrderLineItem where id =: foLineId];
        }
        String foId;
        if(relatedFulfillmentOrder.size() > 0){
            foId = relatedFulfillmentOrder[0].fulfillmentOrder.Id;
        }
        System.debug(foId);
        if(foId != null){
            //HttpRequest httpReqCan = new HttpRequest();
        	httpReq.setEndpoint(host+'/services/data/v57.0/commerce/fulfillment/fulfillment-orders/'+foId+'/actions/cancel-item');
        	//httpReqCan.setMethod('POST');
        	//httpReqCan.setHeader('Content-Type', 'application/json');
        	//httpReqCan.setHeader('Authorization', 'Bearer 00D55000000Vxha!ARIAQEmK_0w8kCnAX.T6xzhjzy6JVvrad_bovappt3a9jOm0LEh.ZeZ1yqKWgccnUheGn3Db7XVlWBKaznH8mmk4SJ7LD1ib');
            httpBody = JSON.serialize(cancelPayload);
        	httpReq.setBody(httpBody);
        	//Http httpCan = new Http();
            //response = http.send(httpReq); //--uncomment later
        	//System.debug(response.getStatus()); //-- uncomment later
        }
        }
        //FO cancellation ends
        
        //FO update starts
        Object updatePayload = mapp.get('update');
        System.debug(updatePayload);
        if(updatePayload != null){
            //HttpRequest httpReqUpd = new HttpRequest();
        	httpReq.setEndpoint(host+'/services/data/v57.0/composite');
        	//httpReqUpd.setMethod('POST');
        	//httpReqUpd.setHeader('Content-Type', 'application/json');
        	//httpReqUpd.setHeader('Authorization', 'Bearer 00D55000000Vxha!ARIAQKMKOQu6quYnvTV5DKh83rR9qUOy4jbZsNRgHaMHJZMkURdB0U61xcux8Kkg125ZszJblgaQgn0XVtY7Ndx.hxMKmTG4');
        	//httpBody = JSON.serialize(updatePayload);
        	//httpReq.setBody(httpBody);
        	//Http httpUpd = new Http();
        	//response = http.send(httpReq); //--uncomment later
        	//System.debug(response.getStatus()); //-- uncomment later
        }
        //FO update ends
    }
}