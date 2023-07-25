public without sharing class VDuplicateService {
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
                                matchedAccounts.add(matchedAccount);

                                if(matchedAccount.IsPersonAccount && paToAdd == null) {
                                    paToAdd = matchedAccount;
                                }
                            }
                        }

                        if(matchedAccounts.size() > 1) {
                            String query = 'select Id, {0} from Account where Id in :matchedAccounts'.replace('{0}', String.join(ACCOUNT_FIELDS, ','));
                            System.debug(query);
                            matchedAccounts = (List<Account>)Database.query(query);

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

        return res;
    }
}