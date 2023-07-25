public with sharing class VFlexSendShipmentNotifController {
    @AuraEnabled
    public static void sendNotification(ID sfOrderItemId) {
        OrderItem ordItem = [select Id, Order.SnipesOrderNumber__c, 
            Order.Account.Name, Order.Account.PersonEmail,
            ItemCarrierName__c, ItemShippingTracking__c
            from OrderItem
            where Id = :sfOrderItemId];

        VFlexShipmentNotification notif = new VFlexShipmentNotification();
        notif.order.id = ordItem.Order.SnipesOrderNumber__c;
        notif.addNotificationChannel(ordItem.Order.Account.Name, ordItem.Order.Account.PersonEmail);
        notif.shipment.carrier = ordItem.ItemCarrierName__c;
        notif.shipment.trackingNumber = ordItem.ItemShippingTracking__c;

        VFlexOrderAPI api = new VFlexOrderAPI();

        System.debug(JSON.serialize(notif));
        api.sendShipmentNotification(notif);

    }
}