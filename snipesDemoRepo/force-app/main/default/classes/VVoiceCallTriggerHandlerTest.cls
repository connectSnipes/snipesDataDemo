@isTest
public class VVoiceCallTriggerHandlerTest {
    @isTest
    static void testCallTimes() {
        CallCenter cc = [select Id from CallCenter limit 1];

        VoiceCall vc = new VoiceCall(
            CallCenterId = cc.Id,
            VendorType = 'ContactCenter',
            CallStartDateTime = DateTime.now().addMinutes(-10),
            CallEndDateTime = DateTime.now(),
            FromPhoneNumber = '555-444-3333',
            ToPhoneNumber = '555-333-4444',
            CallType = 'Bridge'
        );

        insert vc;
        update vc;
    }
}