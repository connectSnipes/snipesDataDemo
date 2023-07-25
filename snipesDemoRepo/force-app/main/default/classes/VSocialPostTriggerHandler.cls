public class VSocialPostTriggerHandler {
    public void beforeInsert(List<SocialPost> newList) {
        autoIgnore(newList);
    }

    private void autoIgnore(List<SocialPost> newList) {
        if(!VSettings.settings.EnableSocialPostTrigger__c) return;

        List<String> keywords = new List<String>();

        for(BlockedSocialKeyword__mdt keywordMeta  : [select Id, MasterLabel, LongKeyword__c
            from BlockedSocialKeyword__mdt]) {
            
            String keyword = keywordMeta.MasterLabel.toLowerCase();
            if(keywordMeta.LongKeyword__c != null) {
                keyword = keywordMeta.LongKeyword__c.toLowerCase();
            }
            
            keywords.add(keyword);
        }

        
        Set<ID> whoIds = new Set<ID>();

        for(SocialPost sp : newList) {
            if(sp.WhoId != null) {
                whoIds.add(sp.WhoId);
            }
        }

        Map<ID, Account> accountMap = new Map<ID, Account>([select Id, IgnoreSocialPosts__c from Account where Id in :whoIds]);

        for(SocialPost sp : newList) {
            if(sp.IsBlocklisted__c) {
                sp.ReviewedStatus = 'Ignore';
                continue;
            }

            Account acc = accountMap.get(sp.WhoId);
            if(acc != null && acc.IgnoreSocialPosts__c) {
                sp.ReviewedStatus = 'Ignore';
                continue;
            }

            if(sp.Content != null) {
                String msg = sp.Content.toLowerCase();

                if(containsKeyword(sp, keywords)) {
                    sp.ReviewedStatus = 'Ignore';
                    continue;
                }
            }
        }
    }

    private Boolean containsKeyword(SocialPost sp, List<String> keywords) {
        Boolean res = false;
        String msg = sp.Content.toLowerCase();

        for(String keyword : keywords) {
            if(msg.contains(keyword)) {
                res = true;
                break;
            }
        }

        return res;
    }

}