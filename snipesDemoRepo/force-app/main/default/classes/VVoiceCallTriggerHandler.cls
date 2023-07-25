public class VVoiceCallTriggerHandler {
    public static final ID BUSINESS_HOURS_ID = [SELECT Id FROM BusinessHours WHERE IsDefault=true].Id;

    public void beforeInsert(List<VoiceCall> newList) {
        updateCallTimes(newList, null);
    }

    public void beforeUpdate(List<VoiceCall> newList, Map<ID, VoiceCall> oldMap) {
        updateCallTimes(newList, oldMap);
    }

    private void updateCallTimes(List<VoiceCall> newList, Map<ID, VoiceCall> oldMap) {
        for(VoiceCall vc : newList) {
            if(vc.CallStartDateTime != null) {
                String dtString = vc.CallStartDateTime.format('a hh', 'America/New_York');
                vc.CallStartTimeHourEST__c = dtString;
                vc.WithinBusinessHours__c = BusinessHours.isWithin(BUSINESS_HOURS_ID, vc.CallStartDateTime);
            }
        }
    }
}