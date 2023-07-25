@RestResource(urlMapping='/CancelAndRecreateFulfillmentOrder/*')
global class CancelAndRecreateFulfillmentOrder {
    @HttpPost
    global static String run(){
        List<String> cancelProductCodeList = new List<String>();
        //Map<String,Object> inputs = (Map<String,Object>)JSON.deserializeUntyped(jsonString);
        //System.debug(inputs.get('inputs'));
        RestRequest req = RestContext.request;
        Blob body = req.requestBody;
        string body1=body.tostring();
        Map<String,Object> inputs = (Map<String,Object>)JSON.deserializeUntyped(body1);
        Object inputObject = inputs.get('inputs');
        String inputObjectString = JSON.serializePretty(inputObject);
        List<Object> inputObjectStringList = (List<Object>)JSON.deserializeUntyped(inputObjectString);
        String cancelMapString = JSON.serializePretty(inputObjectStringList[0]);
        Map<String,Object> cancelMap = (Map<String,Object>)JSON.deserializeUntyped(cancelMapString);
        Object cancels = cancelMap.get('cancels');
        String cancelsString = JSON.serializePretty(cancels);
        Map<String,Object> cancelsStringMap = (Map<String,Object>)JSON.deserializeUntyped(cancelsString);
        for(String str:cancelsStringMap.keyset()){
            cancelProductCodeList.add((String)cancelsStringMap.get(str));
        }
        //System.debug(cancelMapString);
        return inputObjectString;
    }
}