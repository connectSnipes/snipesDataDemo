public class VCordialOrderBatch implements Database.Batchable<sObject>, Schedulable, Database.AllowsCallouts {
    public Database.QueryLocator start(Database.BatchableContext BC) {
        Date cutOff = Date.today().addDays(-1);
        if(Test.isRunningTest()) {
            cutOff = Date.today();
        }

        return Database.getQueryLocator([select Id, Account.PersonEmail, SnipesOrderNumber__c, OrderDate__c, OrderTotalTax__c,
            OrderTotalShipping__c, SnipesOrderTotal__c, Status, (select Id, Pricebookentry.Product2.ProductCode,
            PricebookEntry.Product2.Name, PricebookEntry.Product2.Description, Quantity, UnitPrice, TotalPrice from OrderItems)
            from Order where DAY_ONLY(CreatedDate) = :cutOff
            and Account.PersonEmail != null
            and SentToCordial__c = false]);

        // return Database.getQueryLocator([select Id, Account.PersonEmail, SnipesOrderNumber__c, OrderDate__c, OrderTotalTax__c,
        //     OrderTotalShipping__c, SnipesOrderTotal__c, Status, (select Id, Pricebookentry.Product2.ProductCode,
        //     PricebookEntry.Product2.Name, PricebookEntry.Product2.Description, Quantity, UnitPrice, TotalPrice from OrderItems)
        //     from Order where Id = '8010r000001R2SvAAK'
        //     and Account.PersonEmail != null
        //     and SentToCordial__c = false]);
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<Order> orderList = (List<Order>)scope;

        for(Order ord : orderList) {
            VCordialOrder cordialOrder = VCordialOrder.create(ord);
            VCordialAPI.pushOrder(cordialOrder);

            ord.SentToCordial__c = true;
        }

        update orderList;
    }

    public void finish(Database.BatchableContext BC) {}

    public void execute(SchedulableContext SC) {
        VCordialOrderBatch b = new VCordialOrderBatch();
        Database.executeBatch(b, 10);
    }
}