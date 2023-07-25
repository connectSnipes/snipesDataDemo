@isTest
public class VFlexOrderEventsControllerTest {
    @isTest
    static void testController() {
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

        VFlexOrderEventsController.getEvents('test');
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