trigger VCase on Case (before insert, after insert, after update) {
    if(!VSettings.settings.EnableCaseTrigger__c) return;
    
    VCaseTriggerHandler handler = new VCaseTriggerHandler();

    switch on Trigger.operationType {
        when BEFORE_INSERT {
            handler.beforeInsert(Trigger.new);
        } when AFTER_INSERT {
            handler.afterInsert(Trigger.new);
        } when AFTER_UPDATE {
            handler.afterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}