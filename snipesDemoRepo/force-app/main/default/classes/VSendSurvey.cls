global class VSendSurvey {
    @InvocableMethod(label='Send Survey' description='Sends Surveys')
    global static void sendSurvey(List<SendSurveyInput> surveyInput) {
        for(SendSurveyInput survey : surveyInput) {
            ConnectApi.SurveyInvitationEmailInput ipt = new ConnectApi.SurveyInvitationEmailInput();
            ipt.allowGuestUserResponse = true;
            ipt.allowParticipantsAccessTheirResponse = true;
            ipt.collectAnonymousResponse = false;
            ipt.emailTemplateId =survey.emailTemplateId;
            ipt.fromEmailAddress = survey.orgWideEmailId;
            ipt.isPersonalInvitation = true;
            ipt.recipients = new List<String> { survey.recipients };
            ipt.surveyQuestionIds = new List<String> { survey.surveyQuestionIds };

            ipt.associateRecordsWithRecipients = new List<ConnectApi.AssociateRecordsWithRecipientInput>();

            ConnectApi.AssociateRecordsWithRecipientInput assocInput = new ConnectApi.AssociateRecordsWithRecipientInput();
            assocInput.associateRecordIds = new List<String> { survey.associatedRecordId };
            assocInput.recipientId = survey.recipients;

            ipt.associateRecordsWithRecipients.add(assocInput);

            if(!Test.isRunningTest()) {
                ConnectApi.Surveys.sendSurveyInvitationEmail(survey.surveyId, ipt);
            }
        }
    }

    global class SendSurveyInput {
        @InvocableVariable(label='Survey ID' description='Survey ID' required=true)
        public ID surveyId;
        @InvocableVariable(label='Survey Email Template' description='Survey Email Template' required=true)
        public ID emailTemplateId;
        @InvocableVariable(label='Survey Org Wide Email' description='Survey Org Wide Email ID' required=true)
        public String orgWideEmailId;
        @InvocableVariable(label='Survey Recipients' description='Survey Recipients' required=true)
        public String recipients;
        @InvocableVariable(label='Survey Questions' description='Survey Questions' required=true)
        public String surveyQuestionIds;
        @InvocableVariable(label='Associated Record' description='Associated Record' required=true)
        public ID associatedRecordId;
    }
}