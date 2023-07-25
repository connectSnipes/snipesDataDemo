@isTest
public class VSendSurveyTest {
    @isTest
    static void testSend() {
        VSendSurvey.SendSurveyInput ipt = new VSendSurvey.SendSurveyInput();
        ipt.recipients = 'test@test.com';
        ipt.surveyQuestionIds = 'questionIds';
        

        VSendSurvey.sendSurvey(new List<VSendSurvey.SendSurveyInput> { ipt });
    }
}