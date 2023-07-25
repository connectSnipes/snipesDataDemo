@isTest
public class VFlexOrderAPITest {
    @isTest
    static void testGetOrderEvents() {
        VFlexOrderEvent evt = new VFlexOrderEvent();
        evt.eventType = 'Test';
        evt.carrier = 'Test';
        evt.trackingNumber = 'Test';
        evt.status = 'Test';
        evt.trackingLocation = 'Test';
        evt.statusDetail = 'Test';
        evt.estDeliveryDate = DateTime.now();
        evt.carrierDate = DateTime.now();
        evt.requestDate = DateTime.now();

        TestMock m = new TestMock(new List<VFlexOrderEvent> { evt });
        Test.setMock(HttpCalloutMock.class, m);

        VFlexOrderAPI api = new VFlexOrderAPI();
        api.accessToken = 'Test';
        System.assertNotEquals(null, api.getOrderEvents('Test'));
    }

    @isTest
    static void testCreateWebhook() {
        TestMock m = new TestMock(new Map<String, Object> {});
        Test.setMock(HttpCalloutMock.class, m);

        VFlexOrderAPI api = new VFlexOrderAPI();
        api.accessToken = 'Test';
        api.createWebhook('https://test.com', true);
    }

    @isTest
    static void testDeleteWebhook() {
        TestMock m = new TestMock(new Map<String, Object> {});
        Test.setMock(HttpCalloutMock.class, m);

        VFlexOrderAPI api = new VFlexOrderAPI();
        api.accessToken = 'Test';
        api.deleteWebhook('test');
    }

    @isTest
    static void testSendShipmentNotification() {
        TestMock m = new TestMock(new Map<String, Object> {});
        Test.setMock(HttpCalloutMock.class, m);

        VFlexShipmentNotification notif = new VFlexShipmentNotification();
        notif.addNotificationChannel('Test', 'test@test.com');

        VFlexOrderAPI api = new VFlexOrderAPI();
        api.accessToken = 'Test';
        api.sendShipmentNotification(notif);
    }

    @isTest
    static void testGetWebhooks() {
        TestMock m = new TestMock(new Map<String, Object> {});
        Test.setMock(HttpCalloutMock.class, m);

        VFlexOrderAPI api = new VFlexOrderAPI();
        api.accessToken = 'Test';
        api.getWebhooks();
    }

    @isTest
    static void testAuthenticate() {
        TestMock m = new TestMock(new Map<String, Object> {});
        Test.setMock(HttpCalloutMock.class, m);

        VFlexOrderAPI api = new VFlexOrderAPI();
        api.authenticate();
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