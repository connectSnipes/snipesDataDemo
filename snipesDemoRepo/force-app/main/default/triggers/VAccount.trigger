trigger VAccount on Account (before insert, before update, after insert, after update) {
    if(!VSettings.settings.EnableAccountTrigger__c) return;
    
    VAccountTriggerHandler handler = new VAccountTriggerHandler();

    switch on Trigger.operationType {
        when BEFORE_INSERT {
            handler.beforeInsert(Trigger.new);
        } when BEFORE_UPDATE {
            handler.beforeUpdate(Trigger.new, Trigger.oldMap);
        } when AFTER_INSERT {
            handler.afterInsert(Trigger.new);
        } when AFTER_UPDATE {
            handler.afterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}