@RestResource(UrlMapping='/simplr/getCaseTags')
global with sharing class SimplrGetCaseTagsAction {
	global class SimplrCaseTag {
        global String tag;
        global List<SimplrCaseTag> subTags;
        public SimplrCaseTag(String tag, List<SimplrCaseTag> subTags) {
            this.tag = tag;
            this.subTags = subtags;
        }

        public SimplrCaseTag(String tag) {
            this.tag = tag;
            this.subTags = null;
        }

    }

    @HttpPost
    global static List<SimplrCaseTag> action(String tagFieldName, String subTagFieldName) {
        String objectName = 'Case';
        List<SimplrCaseTag> results = new List<SimplrCaseTag>();
        List<String> tagList = getTags(objectName, tagFieldName);
        if (subTagFieldName != null) {
           Schema.sObjectField subTagField =  Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(subTagFieldName);
           Map<Object, List<String>> tagMap = getSubTags(subTagField);

            for (Object key : tagMap.keySet()) {
                Integer tagListIdx = tagList.indexOf(key.toString());
                if (tagListIdx > -1) {
                    tagList.remove(tagListIdx);
                }
                List<String> tags = tagMap.get(key);
                List<SimplrCaseTag> caseSubTags = new List<SimplrCaseTag>(); 
                for (String tag : tags) {
                    caseSubTags.add(new SimplrCaseTag(tag));
                }
                results.add(new SimplrCaseTag(key.toString(), caseSubTags));
            }

            for (String tag : tagList) {
                results.add(new SimplrCaseTag(tag));
            }
        } else if(tagFieldName != null) {
            for (String tag : tagList) {
                results.add(new SimplrCaseTag(tag));
            }
        }                    
        return results;
    }

    private static Map<Object,List<String>> getSubTags( Schema.sObjectField subTagField ) {
        /* From https://glyntalkssalesforce.blogspot.com/2018/08/dependent-picklist-values-in-apex.html */
        Schema.DescribeFieldResult depend = subTagField.getDescribe();
        Schema.sObjectField controlToken = depend.getController();
        if ( controlToken == null ) return null;
        Schema.DescribeFieldResult control = controlToken.getDescribe();
        List<Schema.PicklistEntry> controlEntries =
        (   control.getType() == Schema.DisplayType.Boolean
        ?   null
        :   control.getPicklistValues()
        );

        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        Map<Object,List<String>> dependentPicklistValues = new Map<Object,List<String>>();
        for ( Schema.PicklistEntry entry : depend.getPicklistValues() ) if ( entry.isActive() )
        {
            List<String> base64chars =
                String.valueOf
                (   ((Map<String,Object>) JSON.deserializeUntyped( JSON.serialize( entry ) )).get( 'validFor' )
                ).split( '' );
            for ( Integer index = 0; index < (controlEntries != null ? controlEntries.size() : 2); index++ )
            {
                Object controlValue =
                (   controlEntries == null
                ?   (Object) (index == 1)
                :   (Object) (controlEntries[ index ].isActive() ? controlEntries[ index ].getLabel() : null)
                );
                Integer bitIndex = index / 6, bitShift = 5 - Math.mod( index, 6 );
                try {
                    if  (   controlValue == null
                        ||  (base64map.indexOf( base64chars[ bitIndex ] ) & (1 << bitShift)) == 0
                        ) continue;
                } catch (Exception e) {
                    continue;
                }
                if ( !dependentPicklistValues.containsKey( controlValue ) )
                {
                    dependentPicklistValues.put( controlValue, new List<String>() );
                }
                dependentPicklistValues.get( controlValue ).add( entry.getLabel() );
            }
        }
        return dependentPicklistValues;
    }

    private static List<String> getTags(String objectName, String fieldName) {
        List<String> tags = new List<String>();

        Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult r = s.getDescribe();
        Map<String,Schema.SObjectField> fields = r.fields.getMap();
        Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple) {
            tags.add(pickListVal.getValue());
        }
        return tags;
    }
}