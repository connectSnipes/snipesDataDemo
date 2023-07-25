public without sharing class VCaseMergeExt {
    public static Integer MAX_CASES = 25;

    private ApexPages.StandardSetController controller;

    public VCaseMergeExt(ApexPages.StandardSetController controller) {
        this.controller = controller;
    }

    private List<String> getCaseFields() {
        List<String> caseFields = new List<String>();

        for(Schema.SObjectField sobjField : Schema.SObjectType.Case.fields.getMap().values()) {
            Schema.DescribeFieldResult dfr = sobjField.getDescribe();

            if(dfr.isUpdateable()) {
                caseFields.add(dfr.getName());
            }
        }

        return caseFields;
    }

    private Map<ID, List<AgentWork>> getAgentWorkMap(List<Case> caseList) {
        Map<ID, List<AgentWork>> agentWorkMap = new Map<ID, List<AgentWork>>();

        for(AgentWork aw : [select Id, WorkItemId from AgentWork where WorkItemId in :caseList]) {
            List<AgentWork> agentWorkList = agentWorkMap.get(aw.WorkItemId);

            if(agentWorkList == null) {
                agentWorkList = new List<AgentWork>();
                agentWorkMap.put(aw.WorkItemId, agentWorkList);
            }

            agentWorkList.add(aw);
        }

        return agentWorkMap;
    }

    public PageReference mergeCases() {
        PageReference res = null;

        List<Case> selectedCaseList = (List<Case>)controller.getSelected();

        if(FeatureManagement.checkPermission('MergeOmniChannelCases') || Test.isRunningTest()) {
            if(selectedCaseList.size() > 1) {
                if(selectedCaseList.size() <= MAX_CASES) {
                    List<String> caseFields = getCaseFields();
                    List<Case> caseList = (List<Case>)Database.query(String.format('select {0} from Case where Id in :selectedCaseList order by CreatedDate', new List<String> { String.join(caseFields, ',') }));
                    Map<ID, List<AgentWork>> agentWorkMap = getAgentWorkMap(caseList);

                    Savepoint sp = Database.setSavepoint();
                    try {
                        Case masterCase = caseList[0];

                        for(Integer i = 1; i < caseList.size(); i++) {
                            Case childCase = caseList[i];

                            for(String caseField : caseFields) {
                                if(masterCase.get(caseField) == null) {
                                    masterCase.put(caseField, childCase.get(caseField));
                                }
                            }

                            List<AgentWork> agentWorkList = agentWorkMap.get(childCase.Id);
                            if(agentWorkList != null) {
                                delete agentWorkList;
                            }

                            String strOwnerId = childCase.OwnerId;
                            if(strOwnerId.startsWith('00G')) {
                                childCase.OwnerId = UserInfo.getUserId();
                                update childCase;
                            }

                            merge masterCase childCase;
                        }

                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, Label.ConfirmCasesMerged));
                    } catch(Exception e) {
                        System.debug(e.getMessage());
                        System.debug(e.getStackTraceString());
                        ApexPages.addMessages(e);
                        Database.rollback(sp);
                    }
                } else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ErrorTooManyCasesSelected.replace('{0}', String.valueOf(MAX_CASES))));    
                }
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ErrorNoCasesSelected));
            }
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ErrorNoOmniCaseMergePermission));
        }
        return res;
    }
}