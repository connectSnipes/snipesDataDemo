public class VFlexOrderEvent {
    @AuraEnabled public String eventType;
    @AuraEnabled public String carrier;
    @AuraEnabled public String trackingNumber;
    @AuraEnabled public String status;
    @AuraEnabled public String trackingLocation;
    @AuraEnabled public String statusDetail;
    @AuraEnabled public DateTime estDeliveryDate;
    @AuraEnabled public DateTime carrierDate;
    @AuraEnabled public DateTime requestDate;
}