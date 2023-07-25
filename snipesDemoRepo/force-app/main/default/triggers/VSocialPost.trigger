trigger VSocialPost on SocialPost (before insert) {
    if(!VSettings.settings.EnableSocialPostTrigger__c) return;
    
    VSocialPostTriggerHandler handler = new VSocialPostTriggerHandler();

    switch on Trigger.operationType {
        when BEFORE_INSERT {
            handler.beforeInsert(Trigger.new);
        }
    }
}