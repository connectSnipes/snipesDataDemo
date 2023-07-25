public without sharing class VContactTriggerHandler {
    public static Boolean CONVERT_TO_PERSON_ACCOUNT_EXECUTED = false;

    public void afterInsert(List<Contact> newList) {
        convertToPersonAccount(newList);
    }

    private void convertToPersonAccount(List<Contact> newList) {
        if(!VSettings.settings.EnableContactToPAConversion__c) return;
        if(CONVERT_TO_PERSON_ACCOUNT_EXECUTED) return;

        CONVERT_TO_PERSON_ACCOUNT_EXECUTED = true;

        List<Contact> contactsToProcess = new List<Contact>();

        for(Contact con : newList) {
            if(con.AccountId == null) {
                contactsToProcess.add(con);
            }
        }

        if(contactsToProcess.size() > 0) {
            VContactToPersonAccountProcess proc = new VContactToPersonAccountProcess(contactsToProcess);
            proc.execute(null);
        }
    }
}