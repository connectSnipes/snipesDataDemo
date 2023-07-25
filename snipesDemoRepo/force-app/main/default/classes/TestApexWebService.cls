@RestResource(urlMapping='/PaymentCapture/*')
global class TestApexWebService {
	@HttpPost
    global static Map<String,String> createResponse(Map<String,String> clientReferenceInformation,Map<String,Map<String,String>> orderInformation,String error) {
       // String code = clientReferenceInformation.get('code');
        //String totalAmount = orderInformation.get('amountDetails').get('totalAmount');
        if(error == null){
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeBooleanField('Success', true);
            gen.writeFieldName('Error');
            gen.writeStartArray();
            gen.writeEndArray();
            gen.writeEndObject();
            //return JSON.serialize((Map<String,Object>)JSON.deserializeUntyped(gen.getAsString()));
            Map<String,String> resMap = new Map<String,String>();
            
            resMap.put('Error','{}');
            resMap.put('Success','true');
            return resMap;
        }
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeBooleanField('Success', false);
        gen.writeFieldName('Error');
        gen.writeStartArray();
        gen.writeStartObject();
        gen.writeNumberField('Error_Code', 400);
        gen.writeStringField('Error_Description', 'INVALID_REQUEST');
        gen.writeEndObject();
        gen.writeEndArray();
        gen.writeEndObject();
        System.debug(gen);
        //return JSON.serialize((Map<String,Object>)JSON.deserializeUntyped(gen.getAsString()));
        Map<String,String> resMap = new Map<String,String>();
        
        resMap.put('Error_Code','400');
        resMap.put('Error_Description','INVALID_REQUEST');
        resMap.put('Success','false');
        return resMap;
    }   
}