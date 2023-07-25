@isTest
public class SimplrGetVersionActionTest {
    static testMethod void testGetVersionAction() {
        System.assertEquals(SimplrUtil.SIMPLR_VERSION, SimplrGetVersionAction.action());
    }
}