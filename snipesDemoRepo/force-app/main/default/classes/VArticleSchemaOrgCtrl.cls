public with sharing class VArticleSchemaOrgCtrl {
    @AuraEnabled
    public static Map<String, Object> getSchemaOrgData(ID recordId) {
        Map<String, Object> res = new Map<String, Object>();

        Knowledge__kav article = [select Id, Title, Answer__c
            from Knowledge__kav
            where Id = :recordId];

        res.put('@context', 'https://schema.org');
        res.put('@type', 'FAQPage');
        res.put('name', article.Title);

        List<Map<String, Object>> mainEntityList = new List<Map<String, Object>>();
        Map<String, Object> mainEntity = new Map<String, Object>();

        mainEntity.put('@type', 'Question');
        mainEntity.put('name', article.Title);

        Map<String, Object> acceptedAnswer = new Map<String, Object>();
        acceptedAnswer.put('@type', 'Answer');

        String answer = article.Answer__c;
        if(answer == null) answer = '';

        acceptedAnswer.put('text', answer.stripHtmlTags());

        mainEntity.put('acceptedAnswer', acceptedAnswer);
        mainEntityList.add(mainEntity);
        res.put('mainEntity', mainEntityList);

        return res;
    }
}