public class VAccountTriggerHandler {
    public static Boolean AFTER_INSERT_HAS_EXECUTED = false;
    public static Boolean AFTER_UPDATE_HAS_EXECUTED = false;
    public static Boolean DISABLE_CORDIAL_UPDATE = false;

    public void beforeInsert(List<Account> newList) {
        updateAccountFields(newList);
    }

    public void beforeUpdate(List<Account> newList, Map<ID, Account> oldMap) {
        updateAccountFields(newList);
    }

    public void afterInsert(List<Account> newList) {
        if(AFTER_INSERT_HAS_EXECUTED) return;
        AFTER_INSERT_HAS_EXECUTED = true;

        //findNearestStore(newList, null);
        sendAccountToCordial(newList);
    }

    public void afterUpdate(List<Account> newList, Map<ID, Account> oldMap) {
        if(AFTER_UPDATE_HAS_EXECUTED) return;
        AFTER_UPDATE_HAS_EXECUTED = true;
        //findNearestStore(newList, oldMap);
        sendAccountToCordial(newList);
    }

    private void sendAccountToCordial(List<Account> newList) {
        if(!VSettings.settings.EnableAccountSendToCordial__c) return;
        if(DISABLE_CORDIAL_UPDATE) return;
        
        List<Account> accList = new List<Account>();

        for(Account acc : newList) {
            if(acc.IsPersonAccount) {
                accList.add(acc.clone(true, true));
            }
        }

        if(accList.size() > 0) {
            VCordialSendContactProcess proc = new VCordialSendContactProcess(accList);
            System.enqueueJob(proc);
        }
    }

    // private void findNearestStore(List<Account> newList, Map<ID, Account> oldMap) {
    //     if(!VSettings.settings.EnableClosestStoreCalculation__c) return;
        
    //     List<Account> accountsToProcess = new List<Account>();

    //     for(Account acc : newList) {
    //         if(oldMap != null) {
    //             Account oldAcc = oldMap.get(acc.Id);

    //             if(acc.PersonMailingLatitude == oldAcc.PersonMailingLatitude
    //                 && acc.PersonMailingLongitude == oldAcc.PersonMailingLongitude) {
    //                 continue;
    //             }
    //         }

    //         if(acc.IsPersonAccount) {
    //             accountsToProcess.add(acc);
    //         }
    //     }
        
    //     if(accountsToProcess.size() > 0) {
    //         VAccountNearestStoreProcess proc = new VAccountNearestStoreProcess([select Id, PersonMailingLatitude, PersonMailingLongitude from Account where Id in :accountsToProcess]);
    //         System.enqueueJob(proc);
    //     }
    // }

    private void updateAccountFields(List<Account> newList) {
        for(Account acc : newList) {
            if(!acc.IsPersonAccount) continue;

            acc.PersonMailingStreet = acc.BillingStreet;
            acc.PersonMailingCity = acc.BillingCity;
            acc.PersonMailingState = acc.BillingState;
            acc.PersonMailingPostalCode = acc.BillingPostalCode;
            acc.PersonMailingCountry = acc.BillingCountry;
            acc.BillingLatitude = acc.PersonMailingLatitude;
            acc.BillingLongitude = acc.PersonMailingLongitude;
            //acc.PersonHasOptedOutOfEmail = !acc.Cordial_Email_Opt_In__c;
            if(acc.Phone != null) {
                acc.Amazon_Connect_Phone__c = acc.Phone.replaceAll('[^0-9]','');
            }
        }
    }

}