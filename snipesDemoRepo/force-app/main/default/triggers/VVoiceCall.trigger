trigger VVoiceCall on VoiceCall (before insert, before update) {
    if(!VSettings.settings.EnableVoiceCallTrigger__c) return;
    
    VVoiceCallTriggerHandler handler = new VVoiceCallTriggerHandler();

    switch on Trigger.operationType {
        when BEFORE_INSERT {
            handler.beforeInsert(Trigger.new);
        } when BEFORE_UPDATE {
            handler.beforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}