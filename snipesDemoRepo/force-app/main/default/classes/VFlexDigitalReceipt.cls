public class VFlexDigitalReceipt {
    public static final ID PRICEBOOK_ID = '01s4S000000hCAzQAM';

    public Order ord { get; private set; }
    public Contact soldToContact { get; private set; }
    public List<OrderItem> orderItemList { get; private set; }

    public String id;
    public String brandId;
    public String webhookId;
    public String attemptId;
    public DateTime created;
    public String type;

    public RequestData data;

    public VFlexDigitalReceipt() {
        ord = new Order();
    }

    public void upsertOrder(Map<String, PricebookEntry> productMap) {
        if(data == null) return;
        if(data.apiRequest.data == null) return;
        if(data.apiRequest.data.receipt == null) return;

        FlexReceipt receipt = data.apiRequest.data.receipt;

        ord = new Order(
            SnipesOrderNumber__c = receipt.transactionNumber,
            OrderID__c = receipt.transactionNumber,
            TransactionID__c = receipt.transactionNumber,
            OrderType__c = receipt.receiptType,
            TransactionDate__c = receipt.receiptDateTime,
            OrderDate__c = receipt.receiptDateTime,
            EffectiveDate = receipt.receiptDateTime.date(),
            SnipesOrderTotal__c = receipt.transactionNetAmount.value,
            SalesAssociate__c = data.apiRequest.data.workstation.workstationAssociate,
            Status = 'Store Purchase',
            Pricebook2Id = PRICEBOOK_ID
        );

        if(data.apiRequest.data.workstation.workstationStore != null) {
            List<Account> pAccount = [select Id from Account 
                where Store__c = :data.apiRequest.data.workstation.workstationStore.storeID
                and Store__c != null limit 1];

            if(pAccount.size() == 1) {
                ord.Store__c = pAccount[0].Id;
            }
        }

        VDuplicateservice svc = new VDuplicateService();

        List<Order> existingOrder = [select Id, Account.IsPersonAccount from Order where SnipesOrderNumber__c = :ord.SnipesOrderNumber__c limit 1];
        soldToContact = createSoldToContact(data.apiRequest.data, receipt);
        if(soldToContact != null) {
            applyDuplicateRules(svc, soldToContact);

            if(soldToContact.LastName != null) {
                if(soldToContact.Id == null) {
                    createSoldToPersonAccount(soldToContact);
                } else {
                    update soldToContact;
                    Account acc = [select Id from Account where PersonContactId = :soldToContact.Id];
                    ord.AccountId = acc.Id;
                }
            } else {
                if(existingOrder.size() == 0 || !existingOrder[0].Account.IsPersonAccount) {
                    ord.AccountId = ord.Store__c;
                }
            }

            ord.BillingStreet = soldToContact.MailingStreet;
            ord.BillingCity = soldToContact.MailingCity;
            ord.BillingStateCode = soldToContact.MailingStateCode;
            ord.BillingPostalCode = soldToContact.MailingPostalCode;
            ord.BillingCountryCode = soldToContact.MailingCountryCode;
        } else {
            if(existingOrder.size() == 0 || !existingOrder[0].Account.IsPersonAccount) {
                ord.AccountId = ord.Store__c;
            }
        }

        upsert ord SnipesOrderNumber__c;

        if(receipt.transactionItem != null && receipt.transactionItem.size() > 0) {
            upsertOrderItems(receipt, productMap);
        } else if(receipt.transactionReturn != null && receipt.transactionReturn.size() > 0) {
            handleReturns(receipt, productMap);
        }
    }

    private void upsertOrderItems(FlexReceipt receipt, Map<String, PricebookEntry> productMap) {
        orderItemList = new List<OrderItem>();

        if(receipt.transactionItem != null && receipt.transactionItem.size() > 0) {

            for(TransactionItem item : receipt.transactionItem) {
                OrderItem oi = new OrderItem(
                    OrderId = ord.Id,
                    PricebookEntryId = productMap.get(item.itemSKUNumber).Id,
                    ItemID__c = ord.Id + '-' + item.itemSKUNumber,
                    Quantity = item.itemQuantity.value,
                    UnitPrice = item.itemPrice.value
                );

                item.oi = oi;

                orderItemList.add(oi);
            }

            upsert orderItemList ItemID__c;

            List<ItemTaxAuthority__c> taxList = new List<ItemTaxAuthority__c>();

            for(TransactionItem item : receipt.transactionItem) {
                OrderItem oi = item.oi;

                if(item.transactionTaxes != null) {
                    for(TransactionTaxes txs : item.transactionTaxes) {
                        ItemTaxAuthority__c taxAuth = new ItemTaxAuthority__c(
                            OrderProduct__c = oi.Id,
                            Order__c = ord.Id,
                            TaxAuthName__c = txs.taxDescription,
                            TaxAuthRate__c = txs.taxPercent
                        );

                        taxList.add(taxAuth);
                    }

                    delete [select Id from ItemTaxAuthority__c where Order__c = :ord.Id];
                    insert taxList;
                }
            }
        }

    }

    private void handleReturns(FlexReceipt receipt, Map<String, PricebookEntry> productMap) {
        if(receipt.transactionReturn != null && receipt.transactionReturn.size() > 0) {
            Set<String> skuSet = new Set<String>();

            for(ItemReturn ir : receipt.transactionReturn) {
                for(TransactionItem item : ir.item) {
                    skuSet.add(item.itemSKUNumber);
                }
            }

            if(skuSet.size() > 0) {
                Map<String, OrderItem> orderProductMap = new Map<String, OrderItem>();

                for(OrderItem orderProd : [select Id, OrderId, PricebookEntry.Product2.ProductCode
                    from OrderItem
                    where OrderId = :ord.Id
                    and PricebookEntry.Product2.ProductCode in :skuSet]) {
                    
                    orderProductMap.put(orderProd.PricebookEntry.Product2.ProductCode, orderProd);
                }

                List<OrderItem> orderProductsToUpdate = new List<OrderItem>();

                for(ItemReturn ir : receipt.transactionReturn) {
                    for(TransactionItem item : ir.item) {
                        OrderItem orderProd = orderProductMap.get(item.itemSKUNumber);
                        if(orderProd != null) {
                            orderProd.Returned__c = true;
                            orderProductsToUpdate.add(orderProd);
                        }
                    }
                }

                update orderProductsToUpdate;
            }

        }
    }

    private Contact createSoldToContact(ReceiptData receiptData, FlexReceipt receipt) {
        Contact res = new Contact(
            Email = receiptData.customerEmailAddress
        );

        if(receipt.transactionSoldTo != null) {
            if(receipt.transactionSoldTo.soldToCustomerName != null) {
                List<String> nameArray = receipt.transactionSoldTo.soldToCustomerName.split(' ');

                String firstName = '';
                String lastName = '';

                if(nameArray.size() == 1) {
                    firstName = nameArray[0];
                    lastName = nameArray[0];

                } else {
                    firstName = nameArray[0];

                    for(Integer i = 1; i < nameArray.size(); i++) {
                        lastName += ' ' + nameArray[i];
                    }

                    lastName = lastName.trim();
                }

                if(receipt.transactionSoldTo.country != null) {
                    res.MailingCountryCode = receipt.transactionSoldTo.country.value;
                }

                res.FirstName = firstName;
                res.LastName = lastName;
                res.Phone = receipt.transactionSoldTo.soldToTelephone1;
                res.MailingStreet = VStringUtil.getString(receipt.transactionSoldTo.addressLine1) + ' ' + VStringUtil.getString(receipt.transactionSoldTo.addressLine2) + ' ' + VStringUtil.getString(receipt.transactionSoldTo.addressLine3);
                res.MailingCity = receipt.transactionSoldTo.city;
                res.MailingPostalCode = receipt.transactionSoldTo.postalCode;
            }
        }

        if(res.LastName == null && res.Email != null) {
            res.LastName = res.Email;
        }

        return res;
    }

    private void createSoldToPersonAccount(Contact soldToContact) {
        Account acc = new Account(
            PersonEmail = soldToContact.email,
            FirstName = soldToContact.FirstName,
            LastName = soldToContact.LastName,
            BillingStreet = soldToContact.MailingStreet,
            BillingCity = soldToContact.MailingCity,
            BillingState = soldToContact.MailingState,
            BillingPostalCode = soldToContact.MailingPostalCode,
            BillingCountry = soldToContact.MailingCountry,
            PersonMailingStreet = soldToContact.MailingStreet,
            PersonMailingCity = soldToContact.MailingCity,
            PersonMailingState = soldToContact.MailingState,
            PersonMailingPostalCode = soldToContact.MailingPostalCode,
            PersonMailingCountry = soldToContact.MailingCountry,
            Phone = soldToContact.Phone,
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId()
        );

        insert acc;
        Account tmpAcc = [select Id, PersonContactId from Account where Id = :acc.Id];
        soldToContact.Id = tmpAcc.PersonContactId;
        ord.AccountId = acc.Id;
    }

    private void applyDuplicateRules(VDuplicateService svc, Contact dupeCheckContact) {
        List<Contact> duplicateResultList = svc.processContacts(new List<Contact> { dupeCheckContact });

        if(duplicateResultList[0] != null) {
            dupeCheckContact.Id = duplicateResultList[0].Id;
        }
    }

    public class RequestData {
        public Boolean accessibility;
        public APIData apiRequest;
    }

    public class APIData {
        public String apiVersion;
        public ReceiptData data;
    }

    public class ReceiptData {
        public String customerEmailAddress;
        public String customerTelephone;
        public FlexReceipt receipt;
        public Workstation workstation;
    }

    public class Workstation {
        public String workstationAssociate;
        public WorkstationStore workstationStore;
    }

    public class WorkstationStore {
        public String storeID;
    }

    public class FlexReceipt {
        public String mode;
        public String receiptType;
        public String receiptBarcodeType;
        public String receiptBarcodeNumber;
        public DateTime receiptDateTime;
        public String transactionLoyalty;
        public String transactionType;
        public String transactionNumber;

        public List<TransactionItem> transactionItem;
        public List<ItemReturn> transactionReturn;
        public TransactionItemPrice transactionGrossAmount;
        public TransactionItemPrice transactionNetAmount;
        //public TransactionItemPrice transactionDiscount;

        public SoldToContact transactionSoldTo;
    }

    public class ItemReturn {
        public List<TransactionItem> item;
    }

    public class TransactionItem {
        public OrderItem oi;
        public String itemName;
        public TransactionItemDesc itemDescription;
        public String itemClassCode;
        public String itemSKUNumber;
        public String itemSerialNumber;
        public String itemModelNumber;
        public String itemBrand;
        public String itemIndustry;
        public String itemManufacturer;
        public TransactionItemPrice itemPrice;
        public TransactionItemPrice itemTotal;
        public TransactionItemQuantity itemQuantity;

        public List<TransactionTaxes> transactionTaxes;
        public TransactionItemPrice transactionGrandAmount;
        public TransactionItemPrice transactionTenderApplied;

    }

    public class SoldToContact {
        public String addressLine1;
        public String addressLine2;
        public String addressLine3;
        public String city;
        public String postalCode;
        public CodedValue country;
        public String soldToCustomerName;
        public String soldToTelephone1;
    }

    public class CodedValue {
        public String value;
        public String code;
    }

    public class TransactionTaxes {
        public String taxDescription;
        public Decimal taxPercent;
        public TransactionItemPrice taxableAmount;
        public TransactionItemPrice taxAmount;
        public String taxTypeCode;
    }

    public class TransactionItemPrice {
        public Decimal value;
    }

    public class TransactionItemQuantity {
        public Decimal value;
    }

    public class TransactionItemDesc {
        public String value;
    }

    
}