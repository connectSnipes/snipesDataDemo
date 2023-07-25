trigger SimplrCaseTrigger on Case (after insert, after update) {
    if(SimplrTriggerControl.DISABLE_CASE_TRIGGER) return;
    
    Integer chunkSize = 10;
    Integer count = 0;
    List<List<Case>> caseLists = new List<List<Case>>();
    List<Case> chunkList = null;
    String caseType = 'case-created';
    if (Trigger.isUpdate) {
        caseType = 'case-updated';
    }

    String originFilters = Label.Simplr_Case_Origin_Filter;
    List<String> acceptedOrigins = null;
    if (originFilters != 'false') {
        acceptedOrigins = originFilters.split(',');
    }

    String typeFilters = Label.Simplr_Case_RecordType_Filter;
    List<String> acceptedTypes = null;
    if (typeFilters != 'false') {
       acceptedTypes = typeFilters.split(',');
    }
    
    for (Case caseObj : Trigger.new) {
        if (count == 0) {
            chunkList = new List<Case>();
            caseLists.add(chunkList);
        }
        Case oldCase = null;
        if (Trigger.oldMap != null) {
            oldCase = Trigger.oldMap.get(caseObj.Id);
        }
        /* If the status is not closed we want it sent to simplr.
         * If the status is closed we do not want it if it was
         * created as closed we also do not want it if a closed case was updated
         * and the status remained closed.
         */
        Boolean sendBasedOnStatus = (caseObj.status != 'Closed'
                                     || (oldCase != null && (oldCase.status != 'Closed' && caseObj.status == 'Closed'))
                                    );
        /* If there is no accepted case origins filter we
         * will take it. If there is make sure the case origin
         * is in the list.
         */
        Boolean sendBasedOnOrigin = (acceptedOrigins == null || acceptedOrigins.indexOf(caseObj.Origin) > -1);
        /* If there is no accepted case type filter we
         * will take it. If there is make sure the case type
         * is in the list.
         */
        Boolean sendBasedOnType = (acceptedTypes == null || acceptedTypes.indexOf(caseObj.Type) > -1);
        if (sendBasedOnStatus && sendBasedOnOrigin && sendBasedOnType) {
            chunkList.add(caseObj);
        }
        count++;
        if (chunkList.size() == chunkSize) {
            count = 0;
        }
    }
    for (List<Case> cases: caseLists) {
        if (cases.size() > 0) {
            String content = SimplrWebhook.buildWebhookJSON(caseType, cases);
            SimplrWebhook.callout(content);
        }
    }
}