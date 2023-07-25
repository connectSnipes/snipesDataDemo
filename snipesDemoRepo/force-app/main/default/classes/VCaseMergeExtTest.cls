@isTest
public class VCaseMergeExtTest {
    @testSetup
    static void setup() {
        Case cse = new Case(
            Subject = 'Test');

        Case cse2 = new Case(
            Subject = 'Test2');

        insert new List<Case> { cse, cse2 };

    }

    @isTest
    static void testMerge() {
        List<Case> caseList = [select Id from Case];
        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(caseList);
        ssc.setSelected(caseList);

        VCaseMergeExt controller = new VCaseMergeExt(ssc);
        controller.mergeCases();

        System.assertEquals(1, [select count() from Case]);

    }

    @isTest
    static void testNotEnoughCasesSelected() {
        List<Case> caseList = [select Id from Case];
        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(caseList);
        ssc.setSelected(new List<Case> { caseList[0] });

        VCaseMergeExt controller = new VCaseMergeExt(ssc);
        controller.mergeCases();
    }

    @isTest
    static void testTooManyCases() {
        List<Case> caseList = [select Id from Case];
        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(caseList);
        ssc.setSelected(caseList);

        VCaseMergeExt controller = new VCaseMergeExt(ssc);
        VCaseMergeExt.MAX_CASES = 1;
        controller.mergeCases();
    }

    @isTest
    static void testError() {
        List<Case> caseList = [select Id from Case];
        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(caseList);
        ssc.setSelected(caseList);

        VCaseMergeExt controller = new VCaseMergeExt(ssc);
        delete caseList;
        controller.mergeCases();
    }
}