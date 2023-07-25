public without sharing class VDuplicateServiceJJ {
    public static List<String> ACCOUNT_FIELDS = new List<String>();

    static {
        Map<String, Schema.SObjectField> accountFields = Schema.SObjectType.Account.fields.getMap();

        for(Schema.SObjectField accountField : accountFields.values()) {
            Schema.DescribeFieldResult dsr = accountField.getDescribe();

            if(dsr.isUpdateable()) {
                if(dsr.getName() != 'Name') {
                    ACCOUNT_FIELDS.add(dsr.getName());
                }
            }
        }
    }

    public List<Contact> processContacts(List<Contact> contactList) {
        List<Contact> res = new List<Contact>();
        
        List<Contact> tmpList = [select Id from Contact where Id in :contactList];
        Set<ID> tmpIds = new Set<ID>();

        for(Contact con : tmpList) {
            tmpIds.add(con.Id);
        }

        tmpList = new List<Contact>();

        for(Contact con : contactList) {
            if(tmpIds.contains(con.Id)) {
                tmpList.add(con);
            }
        }

        contactList = tmpList;

        if(contactList.size() > 0) {
            List<Datacloud.FindDuplicatesResult> dupeList = Datacloud.FindDuplicates.findDuplicates(contactList);

            List<Account> accList = new List<Account>();

            for(Integer i = 0 ;i < dupeList.size(); i++) {
                Datacloud.FindDuplicatesResult rs = dupeList[i];
                Contact currentContact = contactList[i];

                List<DataCloud.DuplicateResult> rsList = rs.getDuplicateResults();
                System.debug(rsList);
                
                if(rsList.size() > 0) {
                    Account paToAdd = null;

                    List<Account> matchedAccounts = new List<Account>();

                    for(DataCloud.DuplicateResult dr : rsList) {
                        for(DataCloud.MatchResult mr : dr.getMatchResults()) {
                            System.debug('MATCHES');
                            System.debug(mr.getMatchRecords().size());
                            for(DataCloud.MatchRecord matchRec : mr.getMatchRecords()) {
                                sObject matchObj = matchRec.getRecord();
                                if(matchObj instanceof Account) {
                                    Account matchedAccount = (Account)matchObj;

                                    if(matchedAccount.IsPersonAccount) {
                                        matchedAccounts.add(matchedAccount);
                                    }
                                }
                            }

                            if(matchedAccounts.size() > 1) {
                                String query = 'select Id, {0} from Account where Id in :matchedAccounts'.replace('{0}', String.join(ACCOUNT_FIELDS, ','));
                                System.debug(query);
                                matchedAccounts = (List<Account>)Database.query(query);

                                Map<ID, Account> matchedAccountMap = new Map<ID, Account>(matchedAccounts);

                                for(DataCloud.MatchRecord matchRec : mr.getMatchRecords()) {
                                    sObject matchObj = matchRec.getRecord();
                                    if(matchObj instanceof Account) {
                                        Account matchedAccount = (Account)matchObj;
                                        matchedAccount = matchedAccountMap.get(matchedAccount.Id);

                                        if(paToAdd == null && matchedAccount.Brand_Origin__c != 'Jimmy Jazz') {
                                            paToAdd = matchedAccount;
                                        }
                                    }
                                }

                                Account master = null;
                                for(Account acc : matchedAccounts) {
                                    if(acc.Id == paToAdd.Id) {
                                        master = acc;
                                        break;
                                    }
                                }

                                for(Account acc : matchedAccounts) {
                                    if(acc.Id == master.Id) continue;

                                    for(String f : ACCOUNT_FIELDS) {
                                        if(master.get(f) == null) {
                                            master.put(f, acc.get(f));
                                        }
                                    }

                                    if(acc.Brand_Origin__c == 'Jimmy Jazz') {
                                        master.JJ_Merged_On_Import__c = true;
                                    }

                                    merge master acc;
                                }
                            }
                            if(paToAdd != null) break;
                        }
                        if(paToAdd != null) break;
                    }
                    accList.add(paToAdd);
                } else {
                    accList.add(null);
                }
            }

            Map<ID, Account> accMap = new Map<ID, Account>([select Id, PersonContactId from Account where Id in :accList]);

            for(Account acc : accList) {
                if(acc != null) {
                    Account personAccount = accMap.get(acc.Id);
                    res.add(new Contact(Id = personAccount.PersonContactId));
                } else {
                    res.add(null);
                }
            }
        }

        return res;
    }
}