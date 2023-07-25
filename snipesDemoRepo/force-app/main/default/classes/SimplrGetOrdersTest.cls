@isTest
public class SimplrGetOrdersTest {
    @testSetup static void setup() {
        Account testAccount = new Account(Name='Test Account');
        insert testAccount;

        Contract testContract = new Contract(AccountId=testAccount.Id);
        insert testContract;

        Profile[] p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];

        User testUser = new User(
            Username= System.now().millisecond() + 'test@email.com',
            LastName='LastName',
            Email='test@email.com',
            Alias='Alias',
            TimeZoneSidKey='America/Los_Angeles',
            LocaleSidKey='en_US',
            EmailEncodingKey='UTF-8',
            LanguageLocaleKey='en_US',
            ProfileId=p[0].Id
        );
        insert testUser;

        Id pricebookId = Test.getStandardPricebookId();

        Product2 prod = new Product2(Name='Test Product', Description='Test Product', isActive=true);
        insert prod;

        PricebookEntry pe = new PricebookEntry(UnitPrice = 1, Product2Id=prod.id, Pricebook2Id=pricebookId, isActive=true);
        insert pe;

        Order testOrder = new Order(
            OwnerId=testUser.Id,
            AccountId=testAccount.Id,
            ContractId=testContract.Id,
            EffectiveDate=Date.today(),
            Status='Draft',
            PriceBook2Id=pricebookId
        );
        insert testOrder;

        OrderItem testOrderItem = new OrderItem(
            OrderId=testOrder.Id,
            Product2Id=prod.Id,
            PricebookEntryId=pe.Id,
            UnitPrice=10,
            Quantity=1
        );
        insert testOrderItem;
    }

    @isTest static void testGetOrdersByOrderIdAction() {
        Order testOrder = [SELECT Id FROM Order ORDER BY EffectiveDate DESC LIMIT 1];
        User testUser = [SELECT Id FROM User ORDER BY CreatedDate DESC LIMIT 1];
        Account testAccount = [SELECT Id FROM Account ORDER BY CreatedDate DESC LIMIT 1];
        Contract testContract = [SELECT Id FROM Contract ORDER BY CreatedDate DESC LIMIT 1];
        OrderItem testOrderItem = [SELECT Id FROM OrderItem ORDER BY CreatedDate DESC LIMIT 1];
        Product2 testProduct = [SELECT Id FROM Product2 ORDER BY CreatedDate DESC LIMIT 1];

        SimplrGetOrderByOrderIdAction.SimplrGetOrderByOrderIdResponse response = SimplrGetOrderByOrderIdAction.action(testOrder.Id);

        System.assertEquals(testOrder.Id, response.orderObjectList[0].orderObject.Id);
        System.assertEquals(testUser.Id, response.orderObjectList[0].userObject.Id);
        System.assertEquals(testAccount.Id, response.orderObjectList[0].accountObject.Id);
        System.assertEquals(testContract.Id, response.orderObjectList[0].contractObject.Id);
        System.assertEquals(testOrderItem.Id, response.orderObjectList[0].orderItemProductObjectList[0].orderItemObject.Id);
        System.assertEquals(testProduct.Id, response.orderObjectList[0].orderItemProductObjectList[0].productObject.Id);
    }

    @isTest static void testGetOrdersByEmailAction() {
        User testUser = [SELECT Id, Email FROM User ORDER BY CreatedDate DESC LIMIT 1];
        Account testAccount = [SELECT Id FROM Account ORDER BY CreatedDate DESC LIMIT 1];
        Contract testContract = [SELECT Id FROM Contract ORDER BY CreatedDate DESC LIMIT 1];
        Product2 testProduct = [SELECT Id FROM Product2 ORDER BY CreatedDate DESC LIMIT 1];
        PricebookEntry pe = [SELECT Id FROM PricebookEntry ORDER BY CreatedDate DESC LIMIT 1];

        // Add second order and order item
        Id pricebookId = Test.getStandardPricebookId();
        Order testOrder = new Order(
            OwnerId=testUser.Id,
            AccountId=testAccount.Id,
            ContractId=testContract.Id,
            EffectiveDate=Date.today(),
            Status='Draft',
            PriceBook2Id=pricebookId
        );
        insert testOrder;

        OrderItem testOrderItem = new OrderItem(
            OrderId=testOrder.Id,
            Product2Id=testProduct.Id,
            PricebookEntryId=pe.Id,
            UnitPrice=10,
            Quantity=1
        );
        insert testOrderItem;

        SimplrGetOrdersByEmailAction.SimplrGetOrdersByEmailResponse response = SimplrGetOrdersByEmailAction.action(testUser.Email);

        System.assertEquals(2, response.orderObjectList.size());
        System.assertEquals(testOrder.Id, response.orderObjectList[1].orderObject.Id);
        System.assertEquals(testUser.Id, response.orderObjectList[0].userObject.Id);
        System.assertEquals(testAccount.Id, response.orderObjectList[0].accountObject.Id);
        System.assertEquals(testContract.Id, response.orderObjectList[0].contractObject.Id);
        System.assertEquals(testOrderItem.Id, response.orderObjectList[1].orderItemProductObjectList[0].orderItemObject.Id);
        System.assertEquals(testProduct.Id, response.orderObjectList[0].orderItemProductObjectList[0].productObject.Id);
    }

    @isTest static void testGetOrdersByOrderIdActionOrderDoesntExist() {
        SimplrGetOrderByOrderIdAction.SimplrGetOrderByOrderIdResponse response = SimplrGetOrderByOrderIdAction.action('12345');
        System.assertEquals(0, response.orderObjectList.size());
    }

    @isTest static void testGetOrdersByEmailActionOrderDoesntExist() {
        SimplrGetOrdersByEmailAction.SimplrGetOrdersByEmailResponse response = SimplrGetOrdersByEmailAction.action('not-existing-test@email.com');
        System.assertEquals(0, response.orderObjectList.size());
    }
}