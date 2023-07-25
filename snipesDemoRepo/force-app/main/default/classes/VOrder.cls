public class VOrder {
    public static final ID PRICEBOOK_ID = '01s4S000000hCAzQAM';

    public String Action;
    public String OrderNumber;
    public String OrderID;
    public String TransactionID;
    public String OrderType;
    public String ParentLinkedOrderID;
    public String ParentLinkedExternalOrderID;
    public String ChildLinkedOrderID;
    public String ChildLinkedOrderExternalID;
    public DateTime TransactionDate;
    public DateTime OrderDate;
    public String OrderStatus;
    public String AffiliateID;
    public String AffiliateExternalID;
    public String AffiliateCompany;
    public String AffiliateType;
    public Decimal OrderTotal;
    public Decimal OrderTotalShipping;
    public Decimal OrderTotalTax;
    public String CouponCode;
    public String SalesAssociate;
    public String SalesAssociateNumber;
    public Decimal GiftCardAmount;
    public DateTime ServicesCreditShipDate;
    public SnipesCustomer Customer;
    public List<SnipesCustomAttributes> CustomAttributes;
    public List<SnipesAddress> OrderShippingAddresses;
    public SnipesShipmentLevelTax ShipmentLevelTax;
    public List<SnipesPayment> Payments;

    public Order ord;
    public List<OrderItem> orderItemList = new List<OrderItem>();
    public List<ItemTaxAuthority__c> taxAuthorityList =  new List<ItemTaxAuthority__c>();
    public List<ItemDiscount__c> itemDiscountList = new List<ItemDiscount__c>();
    public List<Payment__c> paymentList = new List<Payment__c>();
    public Contact soldToContact;
    public Contact shipToContact;

    public void upsertOrder(Map<String, PricebookEntry> productMap) {
        ord = new Order(
            SnipesOrderNumber__c = OrderNumber,
            OrderID__c = OrderID,
            TransactionID__c = TransactionID,
            OrderType__c = OrderType,
            ParentLinkedOrderID__c = ParentLinkedOrderID,
            ParentLinkedExternalOrderID__c = ParentLinkedExternalOrderID,
            ChildLinkedOrderID__c = ChildLinkedOrderID,
            ChildLinkedExternalOrderID__c = ChildLinkedOrderExternalID,
            TransactionDate__c = TransactionDate,
            OrderDate__c = OrderDate,
            EffectiveDate = OrderDate.date(),
            AffiliateCompany__c = AffiliateCompany,
            OrderTotalShipping__c = OrderTotalShipping,
            OrderTotalTax__c = OrderTotalTax,
            SnipesOrderTotal__c = OrderTotal,
            CouponCode__c = CouponCode,
            SalesAssociate__c = SalesAssociate,
            SalesAssociateNumber__c = SalesAssociateNumber,
            GiftCardAmount__c = GiftCardAmount,
            ServicesCreditShipDate__c = ServicesCreditShipDate,
            Status = OrderStatus,
            Pricebook2Id = PRICEBOOK_ID
        );

        if(CustomAttributes != null) {
            for(SnipesCustomAttributes attr : CustomAttributes) {
                if(attr.AttributeName == 'StoreNumber') {
                    List<Account> pAccount = [select Id from Account 
                    where Store__c = :attr.Value
                    and Store__c != null limit 1];

                    if(pAccount.size() == 1) {
                        ord.Store__c = pAccount[0].Id;
                    }

                    break;
                }
            }
        }

        VDuplicateservice svc = new VDuplicateService();

        soldToContact = createSoldToContact();
        if(soldtoContact != null) {
            applyDuplicateRules(svc, soldToContact);

            if(soldToContact.Id == null) {
                createSoldToPersonAccount(soldToContact);
            } else {
                update soldToContact;
                Account acc = [select Id from Account where PersonContactId = :soldToContact.Id];
                ord.AccountId = acc.Id;
            }

            ord.BillingStreet = soldToContact.MailingStreet;
            ord.BillingCity = soldToContact.MailingCity;
            ord.BillingStateCode = soldToContact.MailingStateCode;
            ord.BillingPostalCode = soldToContact.MailingPostalCode;
            ord.BillingCountryCode = soldToContact.MailingCountryCode;
        }

        if(ord.OrderType__c != 'pickup') {
            shipToContact = createShipToContact();
            if(shipToContact != null) {
                applyDuplicateRules(svc, shipToContact);
                if(shipToContact.Id == null) {
                    if(shipToContact.FirstName == soldToContact.FirstName && shipToContact.LastName == soldToContact.LastName) {
                        shipToContact.Id = soldToContact.Id;
                    } else {
                        Account shipToAccount = createPersonAccount(shipToContact);
                        insert shipToAccount;

                        shipToAccount = [select Id, PersonContactId from Account where Id = :shipToAccount.Id];
                        shipToContact.Id = shipToAccount.PersonContactId;
                    }
                } else {
                    upsert shipToContact;
                }
                
                ord.ShipToContactId = shipToContact.Id;
                ord.ShippingStreet = shipToContact.MailingStreet;
                ord.ShippingCity = shipToContact.MailingCity;
                ord.ShippingStateCode = shipToContact.MailingStateCode;
                ord.ShippingPostalCode = shipToContact.MailingPostalCode;
                ord.ShippingCountryCode = shipToContact.MailingCountryCode;
            }
        }

        upsert ord SnipesOrderNumber__c;

        upsertOrderItems(productMap);

        if(ShipmentLevelTax != null) {
            ord.OrderTotalTax__c = ShipmentLevelTax.TotalTax;

            if(ShipmentLevelTax.ItemTaxAuthorities != null && ShipmentLevelTax.ItemTaxAuthorities.ItemTaxAuthorities != null) {
                if(ShipmentLevelTax.ItemTaxAuthorities.ItemTaxAuthorities.size() > 0) {
                    SnipesTaxAuthority ita = ShipmentLevelTax.ItemTaxAuthorities.ItemTaxAuthorities[0];

                    if(ita.ItemTaxAuthorityID != 0) {
                        ItemTaxAuthority__c taxAuth = new ItemTaxAuthority__c(
                            ItemTaxAuthorityID__c = ita.ItemTaxAuthorityID,
                            Order__c = ord.Id,
                            TaxAuthName__c = ita.TaxAuthName,
                            TaxAuthID__c = ita.TaxAuthID,
                            TaxAuthZoneID__c = ita.TaxAuthZoneID,
                            TaxAuthAmount__c = ita.TaxAuthAmount,
                            TaxAuthUnroundedAmount__c = ita.TaxAuthUnroundedAmount,
                            TaxAuthIsVAT__c = ita.TaxAuthIsVAT,
                            TaxAuthVATCode__c = ita.TaxAuthVATCode,
                            TaxAuthRate__c = ita.TaxAuthRate,
                            TaxAuthRuleID__c = ita.TaxAuthRuleID,
                            TaxAuthNumber__c = ita.TaxAuthNumber
                        );

                        upsert taxAuth ItemTaxAuthorityID__c;
                    }
                }
            }
        }

        paymentList = new List<Payment__c>();
        if(Payments != null) {
            for(SnipesPayment p : Payments) {
                Payment__c payment = new Payment__c(
                    Order__c = ord.Id,
                    PaymentID__c = p.ID,
                    AuthID__c = p.AuthID,
                    TransactionType__c = p.TransactionType,
                    Amount__c = p.Amount,
                    AmountCaptured__c = p.AmountCaptured,
                    AmountFulFilled__c = p.AmountFulFilled,
                    AmountRemaining__c = p.AmountRemaining,
                    ExternalCreateDate__c = p.CreateDate,
                    PaymentTender__c = p.PaymentTender,
                    TypeCode__c = p.TypeCode,
                    TypeID__c = p.TypeID,
                    AuthOrderNumber__c = p.AuthOrderNumber,
                    CardAuthCode__c = p.CardAuthCode,
                    RequestToken__c = p.RequestToken,
                    SettlementData__c = p.SettlementData,
                    CreditType__c = p.CreditType,
                    CreditID__c = p.CreditID,
                    ItemID__c = p.ItemID,
                    GiftCardNumber__c = p.GiftCardNumber,
                    CardExp__c = p.CardExp,
                    PaymentDisplay__c = p.PaymentDisplay
                );

                paymentList.add(payment);
            }

            upsert paymentList PaymentID__c;
        }
    }

    private void upsertOrderItems(Map<String, PricebookEntry> productMap) {
        orderItemList = new List<OrderItem>();
        taxAuthorityList =  new List<ItemTaxAuthority__c>();
        itemDiscountList = new List<ItemDiscount__c>();

        SnipesAddress ShippingAddress = OrderShippingAddresses[0];

        for(SnipesItem item : ShippingAddress.Items) {
            if(item.ItemProduct == null) continue;

            OrderItem oi = new OrderItem(
                OrderId = ord.Id,
                PricebookEntryId = productMap.get(item.ItemProduct.OptionSKU).Id,
                ItemID__c = item.ItemID,
                ItemType__c = item.OrderItemType,
                ItemStatusID__c = item.ItemStatusId,
                ItemStatusDescription__c = item.ItemStatusDescription,
                Quantity = item.Quantity,
                UnitPrice = item.ItemPrice,
                ItemCost__c = item.ItemCost,
                ItemShipping__c = item.ItemShipping,
                ItemShippingTracking__c = item.ItemShippingTracking,
                ItemCarrierName__c = item.ItemShippingCarrierName,
                ItemCarrierService__c = item.ItemShippingCarrierService,
                ItemCreditAmount__c = item.ItemCreditAmount,
                ItemDiscountDetailsTotal__c = item.ItemDiscountDetailsTotal,
                ItemCouponAmount__c = item.ItemCouponAmount,
                ItemTax__c = item.ItemTax,
                ItemShippingTax__c = item.ItemShippingTax,
                ItemTransactionDate__c = item.ItemTransactionDate,
                ItemGiftWrap__c = item.ItemGiftWrap,
                ItemGiftWrapCost__c = item.ItemGiftWrapCost,
                ItemPersonalization__c = item.ItemPersonalization,
                MerchPONumber__c = item.MerchPONumber,
                LineType__c = item.LineType
            );

            orderItemList.add(oi);
            item.oi = oi;
        }

        upsert orderItemList ItemID__c;

        for(SnipesItem item : ShippingAddress.Items) {
            OrderItem oi = item.oi;

            if(item.ItemTaxAuthorities != null && item.ItemTaxAuthorities.ItemTaxAuthorities != null) {
                for(SnipesTaxAuthority ita : item.ItemTaxAuthorities.ItemTaxAuthorities) {
                    if(ita.ItemTaxAuthorityID == 0) continue;
                    
                    ItemTaxAuthority__c taxAuth = new ItemTaxAuthority__c(
                        ItemTaxAuthorityID__c = ita.ItemTaxAuthorityID,
                        OrderProduct__c = oi.Id,
                        Order__c = ord.Id,
                        TaxAuthName__c = ita.TaxAuthName,
                        TaxAuthID__c = ita.TaxAuthID,
                        TaxAuthZoneID__c = ita.TaxAuthZoneID,
                        TaxAuthAmount__c = ita.TaxAuthAmount,
                        TaxAuthUnroundedAmount__c = ita.TaxAuthUnroundedAmount,
                        TaxAuthIsVAT__c = ita.TaxAuthIsVAT,
                        TaxAuthVATCode__c = ita.TaxAuthVATCode,
                        TaxAuthRate__c = ita.TaxAuthRate,
                        TaxAuthRuleID__c = ita.TaxAuthRuleID,
                        TaxAuthNumber__c = ita.TaxAuthNumber
                    );

                    taxAuthorityList.add(taxAuth);
                }

                if(taxAuthorityList.size() > 0) {
                    upsert taxAuthorityList ItemTaxAuthorityID__c;
                }
            }

            if(item.ItemDiscounts != null && item.ItemDiscounts.ItemDiscounts != null) {
                for(SnipesItemDiscount d : item.ItemDiscounts.ItemDiscounts) {
                    ItemDiscount__c itemDisc = new ItemDiscount__c(
                        ItemDiscountID__c = d.ItemDiscountID,
                        OrderProduct__c = oi.Id,
                        ItemDiscNo__c = d.ItemDiscNo,
                        ItemDiscName__c = d.ItemDiscName,
                        ItemDiscDesc__c = d.ItemDiscDesc,
                        ItemDiscAmount__c = d.ItemDiscAmount,
                        ItemDiscLevel__c = d.ItemDiscLevel,
                        ItemDiscIsLoyalty__c = d.ItemDiscIsLoyalty,
                        ItemDiscIsEmployee__c = d.ItemDiscIsEmployee,
                        ItemDiscAuthorizedBy__c = d.ItemDiscAuthorizedBy,
                        ItemDiscAuthorizedByCaptureMethod__c = d.ItemDiscAuthorizedByCaptureMethod,
                        ItemDiscPromoNo__c = d.ItemDiscPromoNo,
                        ItemDiscPromoName__c = d.ItemDiscPromoName,
                        ItemDiscReasonCode__c = d.ItemDiscReasonCode,
                        ItemDiscGenInfo__c = d.ItemDiscGenInfo,
                        ItemDiscCouponNo__c = d.ItemDiscCouponNo,
                        ItemDiscPercent__c = d.ItemDiscPercent
                    );

                    itemDiscountList.add(itemDisc);
                }

                if(itemDiscountList.size() > 0) {
                    upsert itemDiscountList ItemDiscountID__c;
                }
            }
        }
    }

    private Contact createSoldToContact() {
        String country = Customer.BillingAddress.Country;
        if(country == 'USA') {
            country = 'US';
        }


        Contact res = new Contact(
            CustomerID__c = Customer.CustomerID,
            FirstName = Customer.BillingAddress.FirstName,
            LastName = Customer.BillingAddress.LastName,
            Email = Customer.Emails != null ? Customer.Emails[0].Email : null,
            Phone = Customer.BillingAddress.PhoneNumbers != null ? Customer.BillingAddress.PhoneNumbers[0].Phone : null,
            MailingStreet = Customer.BillingAddress.Address1 + (Customer.BillingAddress.Address2 != null ? ' ' + Customer.BillingAddress.Address2 : ''),
            MailingCity = Customer.BillingAddress.City,
            MailingStateCode = Customer.BillingAddress.State,
            MailingPostalCode = Customer.BillingAddress.Zip,
            MailingCountryCode = country
        );

        return res;
    }

    private Contact createShipToContact() {
        SnipesAddress ShippingAddress = OrderShippingAddresses[0];

        String country = ShippingAddress.Country;
        if(country == 'USA') {
            country = 'US';
        }

        Contact res = new Contact(
            FirstName = ShippingAddress.FirstName,
            LastName = ShippingAddress.LastName,
            Email = Customer.Emails != null ? Customer.Emails[0].Email : null,
            Phone = ShippingAddress.PhoneNumbers != null ? ShippingAddress.PhoneNumbers[0].Phone : null,
            MailingStreet = ShippingAddress.Address1 + (ShippingAddress.Address2 != null ? ' ' + ShippingAddress.Address2 : ''),
            MailingCity = ShippingAddress.City,
            MailingStateCode = ShippingAddress.State,
            MailingPostalCode = ShippingAddress.Zip,
            MailingCountryCode = country
        );

        return res;
    }

    private Account createPersonAccount(Contact con) {
        return new Account(
            PersonEmail = con.email,
            FirstName = con.FirstName,
            LastName = con.LastName,
            BillingStreet = con.MailingStreet,
            BillingCity = con.MailingCity,
            BillingState = con.MailingState,
            BillingPostalCode = con.MailingPostalCode,
            BillingCountry = con.MailingCountry,
            PersonMailingStreet = con.MailingStreet,
            PersonMailingCity = con.MailingCity,
            PersonMailingState = con.MailingState,
            PersonMailingPostalCode = con.MailingPostalCode,
            PersonMailingCountry = con.MailingCountry,
            Phone = con.Phone,
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId()
        );
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

    public class SnipesCustomAttributes {
        public Decimal ID;
        public String AttributeName;
        public String Value;
        public String Option;
    }

    public class SnipesAddress {
        public Decimal AddressID;
        public String FirstName;
        public String LastName;
        public String Company;
        public String Address1;
        public String Address2;
        public String City;
        public String State;
        public String Zip;
        public String Country;
        public List<SnipesPhone> PhoneNumbers;
        public List<SnipesItem> Items;
    }

    public class SnipesProduct {
        public Decimal ProductID;
        public String ProductName;
        public String SKU;
        public String AlternateSKU;
        public String OptionSKU;
        public String OptionText;
        
    }

    public class SnipesTaxAuthorityList {
        public List<SnipesTaxAuthority> ItemTaxAuthorities;
    }

    public class SnipesTaxAuthority {
        public Decimal ItemTaxAuthorityID;
        public Decimal ItemID;
        public String TaxAuthName;
        public Decimal TaxAuthID;
        public Decimal TaxAuthZoneID;
        public Decimal TaxAuthAmount;
        public Decimal TaxAuthUnroundedAmount;
        public Boolean TaxAuthIsVAT;
        public String TaxAuthVATCode;
        public Decimal TaxAuthRate;
        public Decimal TaxAuthRuleID;
        public Decimal TaxAuthNumber;
    }

    public class SnipesItemDiscountList {
        public List<SnipesItemDiscount> ItemDiscounts;
    }

    public class SnipesItemDiscount {
        public Decimal ItemDiscountID;
        public Decimal ItemID;
        public Decimal ItemDiscNo;
        public String ItemDiscName;
        public String ItemDiscDesc;
        public Decimal ItemDiscAmount;
        public String ItemDiscLevel;
        public Boolean ItemDiscIsLoyalty;
        public Boolean ItemDiscIsEmployee;
        public String ItemDiscAuthorizedBy;
        public String ItemDiscAuthorizedByCaptureMethod;
        public Decimal ItemDiscPromoNo;
        public String ItemDiscPromoName;
        public String ItemDiscReasonCode;
        public String ItemDiscReasonDesc;
        public String ItemDiscGenInfo;
        public String ItemDiscCouponNo;
        public Decimal ItemDiscPercent;
    }
    public class SnipesItem {
        public OrderItem oi;

        public String ItemID;
        public String ItemType;
        public String OrderItemType;
        public String ItemStatusId;
        public String ItemStatusDescription;
        public Decimal Quantity;
        public Decimal ItemPrice;
        public Decimal ItemCost;
        public Decimal ItemTotal;
        public Decimal ItemShipping;
        public String ItemShippingTracking;
        public String ItemShippingCarrierName;
        public String ItemShippingCarrierService;
        public Decimal ItemCreditAmount;
        public Decimal ItemDiscountDetailsTotal;
        public Decimal ItemCouponAmount;
        public Decimal ItemTax;
        public Decimal ItemShippingTax;
        public DateTime ItemTransactionDate;
        public String SupplierName;
        public Boolean ItemGiftWrap;
        public Decimal ItemGiftWrapCost;
        public String ItemPersonalization;
        public SnipesProduct ItemProduct;
        public SnipesTaxAuthorityList ItemTaxAuthorities;
        public SnipesItemDiscountList ItemDiscounts;

        public String MerchPONumber;
        public String LineType;

        
    }

    public class SnipesPayment {
        public Decimal ID;
        public Decimal AuthID;
        public String TransactionType;
        public Decimal Amount;
        public Decimal AmountCaptured;
        public Decimal AmountFulFilled;
        public Decimal AmountRemaining;
        public DateTime CreateDate;
        public String PaymentTender;
        public String TypeCode;
        public String TypeID;
        public String AuthOrderNumber;
        public String CardAuthCode;
        public String RequestToken;
        public String SettlementData;
        public String CreditType;
        public Decimal CreditID;
        public Decimal ItemID;
        public String GiftCardNumber;
        public String CardExp;
        public String PaymentDisplay;
    }

    public class SnipesShipmentLevelTax {
        public Decimal TotalTax;
        public SnipesTaxAuthorityList ItemTaxAuthorities;
    }

    public class SnipesPhone {
        public String Phone;
        public String Type;
    }

    public class SnipesCustomer {
        public Decimal CustomerID;
        public SnipesAddress BillingAddress;
        public List<SnipesEmail> Emails;
    }

    public class SnipesEmail {
        public String Email;
    }

    public class OrderException extends Exception {}
}