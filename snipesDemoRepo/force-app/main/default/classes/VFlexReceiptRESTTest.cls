@isTest
public class VFlexReceiptRESTTest {
    @isTest
    static void testService() {
        RestContext.request = new RestRequest();
        RestContext.request.requestBody = Blob.valueOf(VFlexDigitalReceiptTest.TEST_RECORD_2);
        RestContext.response = new RestResponse();

        VFlexReceiptREST.doPost();
    }
}