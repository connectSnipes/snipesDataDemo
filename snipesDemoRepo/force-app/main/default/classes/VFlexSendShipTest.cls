@isTest
public class VFlexSendShipTest {
    @isTest
    static void testController() {
        Account acc = new Account(Name = 'Test');
        insert acc;

        Order ord = new Order(EffectiveDate = Date.today(), AccountId = acc.Id, Status = 'Draft',
            Pricebook2Id = Test.getStandardPricebookId());
        insert ord;

        Product2 prod = new Product2(Name = 'Test', IsActive = true);
        insert prod;

        PricebookEntry pbEnt = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = prod.Id,
            UnitPrice = 100,
            IsActive = true
        );

        insert pbEnt;

        OrderItem ordItem = new OrderItem(
            OrderId = ord.Id,
            PricebookEntryId = pbEnt.Id,
            UnitPrice = 100,
            Quantity = 1
        );

        insert ordItem;

        TestMock m = new TestMock(new Map<String, Object> {});
        Test.setMock(HttpCalloutMock.class, m);

        Test.startTest();
        VFlexSendShipmentNotifController.sendNotification(ordItem.Id);
        Test.stopTest();
    }

    private class TestMock implements HttpCalloutMock {
        public Object payload { get; set; }
        public TestMock(Object payload) {
            this.payload = payload;
        }

        public HttpResponse respond(HttpRequest req) {
            HttpResponse resp = new HttpResponse();
            resp.setStatusCode(200);
            resp.setBody(JSON.serialize(payload));

            return resp;
        }
    }
}