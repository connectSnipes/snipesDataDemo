public class VSettings {
    public static final String SETTING_NAME = Test.isRunningTest() ? 'TestContext' : 'Default';

    private static GeneralSetting__mdt sSettings;

    public static GeneralSetting__mdt settings {
        get {
            if(sSettings == null) {
                sSettings = [select Id, MasterLabel, DeveloperName, EnableCaseTrigger__c, EnableCaseSendSurvey__c,
                    EnableContactTrigger__c, EnableContactToPAConversion__c, SnipesClientID__c, SnipesClientSecret__c,
                    SnipesBrandId__c, SnipesTokenEndpoint__c, SnipesAPIEndpoint__c, EnableSocialPostTrigger__c,
                    EnableVoiceCallTrigger__c, APILogRetention__c, EnableAccountTrigger__c, EnableClosestStoreCalculation__c,
                    CordialAPIKeyQC__c, CordialEndpoint__c, LastCordialContactPull__c, EnableAccountSendToCordial__c,
                    EnableAmazonCases__c, CallbackQueueID__c
                    from GeneralSetting__mdt
                    where DeveloperName = :SETTING_NAME];
            }

            return sSettings;
        }
    }

    public static void updateLastCordialContactPull(DateTime dt) {
        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
        Metadata.CustomMetadata ctmMetadata = new Metadata.CustomMetadata();
        ctmMetadata.fullName = 'GeneralSetting.Default';
        ctmMetadata.label = 'Default';
        
        Metadata.CustomMetadataValue ctmValue = new Metadata.CustomMetadataValue();
        ctmValue.field = 'LastCordialContactPull__c';
        ctmValue.value = dt;

        ctmMetadata.values.add(ctmValue);
        mdContainer.addMetadata(ctmMetadata);

        if(!Test.isRunningTest()) {
            Metadata.Operations.enqueueDeployment(mdContainer, new SettingUpdateCallback());
        }
    }

    private class SettingUpdateCallback implements Metadata.DeployCallback {
        public void handleResult(Metadata.DeployResult result, Metadata.DeployCallbackContext ctx) {
            System.debug(result);
        }
    }
}