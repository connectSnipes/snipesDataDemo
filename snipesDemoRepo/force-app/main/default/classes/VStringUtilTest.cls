@isTest
public class VStringUtilTest {
    @isTest
    static void testUtil() {
        System.assertNotEquals(null, VStringUtil.getString(null));
        System.assertNotEquals(null, VStringUtil.getString('str'));
    }
}