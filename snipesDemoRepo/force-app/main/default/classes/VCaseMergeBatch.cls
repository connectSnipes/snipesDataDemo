public class VCaseMergeBatch implements Database.Batchable<sObject>, Database.Stateful {
    public static List<String> CASE_FIELDS = new List<String>();
    private List<String> errorList = new List<String>();

    static {
        for(Schema.SObjectField sobjField : Schema.SObjectType.Case.fields.getMap().values()) {
            Schema.DescribeFieldResult dfr = sobjField.getDescribe();

            if(dfr.isUpdateable()) {
                CASE_FIELDS.add(dfr.getName());
            }
        }
    }

    // ONE TIME BATCH TO MERGE CASES
    // DESIGNED TO RUN ON BATCH SIZE OF 1
    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'select Id, {0} from Case where OwnerId in (\'00G4S000000pYyr\', \'00G4S000000pYz1\') and IsClosed = false and AccountId != null order by CreatedDate asc'.replace('{0}', String.join(CASE_FIELDS, ','));
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<Case> caseList = (List<Case>)scope;
        Savepoint sp = Database.setSavepoint();

        SimplrTriggerControl.DISABLE_CASE_TRIGGER = true;
        VAccountTriggerHandler.DISABLE_CORDIAL_UPDATE = true;
        
        try {
            for(Case cse : caseList) {
                String query = 'select Id, {0} from Case where AccountId = \'{1}\' and OwnerId in (\'00G4S000000pYyr\', \'00G4S000000pYz1\') and IsClosed = false and Id != \'{3}\' order by CreatedDate asc'.replace('{0}', String.join(CASE_FIELDS, ','))
                                                                                                                                                                                                       .replace('{1}', cse.AccountId)
                                                                                                                                                                                                       .replace('{3}', cse.Id);
                List<Case> otherCases = (List<Case>)Database.query(query);

                if(otherCases.size() > 0) {
                    delete [select Id from AgentWork where WorkItemId in :otherCases];

                    for(Case childCase : otherCases) {
                        for(String caseField : CASE_FIELDS) {
                            if(caseField == 'Description' || caseField == 'Subject') continue;

                            if(cse.get(caseField) == null) {
                                cse.put(caseField, childCase.get(caseField));
                            }
                        }

                        List<String> subjects = new List<String>();
                        subjects.add(getString(cse.Subject));
                        subjects.add(getString(childCase.Subject));
                        cse.Subject = String.join(subjects, ', ').left(255);

                        List<String> descriptions = new List<String>();
                        descriptions.add(getString(cse.Description));
                        descriptions.add(getString(childCase.Description));
                        cse.Description = String.join(descriptions, '\n').left(32000);

                        childCase.OwnerId = UserInfo.getUserId();
                    }

                    update otherCases;

                    for(Case childCase : otherCases) {
                        merge cse childCase;
                    }
                }
            }
        } catch(Exception e) {
            if(!Test.isRunningTest()) {
                Database.rollback(sp);
            }
            errorList.add(e.getMessage());
        }
    }

    public void finish(Database.BatchableContext BC) {
        if(errorList.size() > 0) {
            ContentVersion cv = new ContentVersion(
                Title = 'Merge Results',
                VersionData = Blob.valueOf(String.join(errorList, '\n')),
                PathOnClient = 'MergeResults.txt'
            );

            insert cv;
            
        }
    }

    private String getString(String ipt) {
        if(ipt == null) ipt = '';
        return ipt;
    }
}