@RestResource(UrlMapping='/simplr/getversion')
global with sharing class SimplrGetVersionAction {
    @HttpPost
    global static String action() {
        return SimplrUtil.SIMPLR_VERSION;
    }
}