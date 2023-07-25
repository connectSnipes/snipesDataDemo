trigger VContact on Contact (after insert) {
    if(!VSettings.settings.EnableContactTrigger__c) return;

    VContactTriggerHandler handler = new VContactTriggerHandler();

    switch on Trigger.operationType {
        when AFTER_INSERT {
            handler.afterInsert(Trigger.new);
        }
    }
}