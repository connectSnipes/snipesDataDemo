public class VCaseTriggerHandler {
    public void beforeInsert(List<Case> newList) {
        matchAmazonCases(newList);
    }
    
    public void afterInsert(List<Case> newList) {
        deleteDuplicateAmazonCases(newList);
    }
    
    public void afterUpdate(List<Case> newList, Map<ID, Case> oldMap) {
        sendSurveys(newList, oldMap);
    }
    
    private void deleteDuplicateAmazonCases(List<Case> newList) {
        if(!VSettings.settings.EnableAmazonCases__c) return;
        
        List<Case> toProcess = new List<Case>();
        Set<String> phoneSet = new Set<String>();
        
        for(Case cse : newList) {
            if(cse.Type == 'Callback Request' 
               && cse.OwnerId == VSettings.settings.CallbackQueueID__c
               && cse.Amazon_Connect_Phone__c != null) {
                   toProcess.add(cse);
                   phoneSet.add(cse.Amazon_Connect_Phone__c);
        	}
        }
        
        if(toProcess.size() > 0) {
            Map<String, Case> caseMap = new Map<String, Case>();
            
            for(Case cse : [select Id, Amazon_Connect_Phone__c 
                            from Case
                           	where Amazon_Connect_Phone__c in :phoneSet
                            and Type = 'Callback Request'
                            and OwnerId = :VSettings.settings.CallbackQueueID__c
                            and IsClosed = false
                            and Id not in :toProcess]) {
				caseMap.put(cse.Amazon_Connect_Phone__c, cse);
			}
            
            List<Case> toDelete = new List<Case>();
            
            for(Case cse : toProcess) {
                if(caseMap.containsKey(cse.Amazon_Connect_Phone__c)) {
                    toDelete.add(new Case(ID = cse.Id));
                }
            }
            
            if(toDelete.size() > 0) {
                delete toDelete;
            }
        }
    	
    	
    }
    
    private void matchAmazonCases(List<Case> newList) {
        if(!VSettings.settings.EnableAmazonCases__c) return;
        
        Set<String> phoneSet = new Set<String>();
        
        List<Case> toProcess = new List<Case>();
        for(Case cse : newList) {
            if(cse.Type == 'Callback Request' && cse.Amazon_Connect_Phone__c != null) {
                String phone = cse.Amazon_Connect_Phone__c;
                if(phone != null) {
                    if(phone.startsWith('+1')) { phone = phone.substring(2); }
                	phoneSet.add(phone);
                    
                    toProcess.add(cse);
                }
            }
        }
        
        if(phoneSet.size() > 0) {
            Map<String, Account> accountMap = new Map<String, Account>();
            
            for(Account acc : [select Id, Amazon_Connect_Phone__c, PersonContactId from Account where Amazon_Connect_Phone__c in :phoneSet and IsPersonAccount = true]) {
                accountMap.put(acc.Amazon_Connect_Phone__c, acc);
            }
            
            for(Case cse : toProcess) {
                String phone = cse.Amazon_Connect_Phone__c;
                if(phone.startsWith('+1')) { phone = phone.substring(2); }
                
                Account acc = accountMap.get(phone);
                if(acc != null) {
                	cse.AccountId = acc.Id;
                    cse.ContactId = acc.PersonContactId;
                }
            }
        }
    }

    private void sendSurveys(List<Case> newList, Map<ID, Case> oldMap) {
        if(!VSettings.settings.EnableCaseSendSurvey__c) return;
        
        List<Case> casesToProcess = new List<Case>();

        for(Case cse : newList) {
            Case oldCse = oldMap.get(cse.Id);

            if(cse.Survey_Delivered__c) continue;
            if(cse.ContactId == null) continue;
            if(cse.Survey_Sent_Date__c == oldCse.Survey_Sent_Date__c) continue;

            if(cse.Survey_Sent_Date__c == Date.today()) {
                casesToProcess.add(cse);
            }
        }

        if(casesToProcess.size() > 0) {
            for(Case cse : casesToProcess) {
                Map<String, String> params = new Map<String, String> {
                    'var_CaseID'            =>  cse.Id,
                    'var_contactID'         =>  cse.ContactId
                };
    
                Flow.Interview.vSurveyTrigger flow = new Flow.Interview.vSurveyTrigger(params);
                if(!Test.isRunningTest()) {
                    flow.start();
                }
            }
        }
    }
}