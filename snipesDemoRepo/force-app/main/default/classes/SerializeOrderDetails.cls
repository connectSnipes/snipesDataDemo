//author - Hemant Kumar Patel(hemant_patel@perfaware.com)
public with sharing class SerializeOrderDetails {
    @InvocableMethod(label = 'Serialize Order Details')
    public static  List<OutputParameters> serializeAccount(List<InputParameters> input){
        List<OutputParameters> output = new List<OutputParameters>();
        String accId = input[0].AccountId;
        String ordNum = input[0].OrderSumNumber;
        List<Account> acc = [SELECT FirstName,LastName,Phone,PersonEmail from Account where Id =: accId];
        
        List<Order> ord = [SELECT Id,Name,EffectiveDate,OrderedDate,BillingStreet,BillingCity,BillingStateCode,BillingPostalCode
                            ,BillingCountry,OrderReferenceNumber,Type,ExternalAffId__c,OrderAffiliateType__c,
                           aptosOrderStatusID__c,TotalTaxAmount,GrandTotalAmount,TotalAmount,TotalAdjustedProductAmount,
                           TotalAdjustedDeliveryAmount,TotalAdjustedDeliveryTaxAmount,Order_Discount_Details_Total__c,
                           BillingPhoneNumber,BillingEmailAddress,createdBy__c from Order where OrderReferenceNumber =: ordNum];
        //List<OrderAdjustmentGroup> ordAdjGrp = [SELECT Id,Name from OrderAdjustmentGroup where orderId =: ord[0].Id];
        
        List<OrderSummary> ordSum = [SELECT Id,TotalAdjustedProductAmount from OrderSummary 
                                     where OriginalOrderId =: ord[0].Id];
        
        List<OrderPaymentSummary> ordPaySum = [SELECT Type,PaymentMethodId from OrderPaymentSummary where OrderSummary.OrderNumber =:ordNum];
        String customData1 = 'CREDIT_CARD';
        if(ordPaySum.size() > 0 && ordPaySum[0].Type != null){
            if(ordPaySum[0].Type == 'PayPal' || ordPaySum[0].Type == 'DW_APPLE_PAY' || ordPaySum[0].Type == 'DW_GOOGLE_PAY'){
                customData1 = ordPaySum[0].Type;
            }
        }
        String paypalOrderId = '';
        Integer ordPaymentId = 1;
        if(ordPaySum.size() > 0 && ordPaySum[0].Type != null && ordPaySum[0].Type == 'PayPal'){
            List<DigitalWallet> digiWalList = [SELECT Id,paypalOrderID__c from DigitalWallet where Id =: ordPaySum[0].PaymentMethodId];
            If(digiWalList[0].paypalOrderID__c != null){
                paypalOrderId = digiWalList[0].paypalOrderID__c;
                ordPaymentId = 7;
            }
        }
                           
        List<OrderDeliveryGroup> ordDelGrp = [SELECT DeliverToCity,DeliverToCountry,DeliverToName,DeliverToPostalCode,
                                             DeliverToState,DeliverToStreet,PhoneNumber,aptosShipCode__c,OrderDeliveryMethod.Name
                                              from OrderDeliveryGroup where OrderId =: ord[0].Id];
        
        List<OrderItem> productOrdItem = [SELECT Id,Quantity,UnitPrice,ItemGiftWrap__c,ItemGiftMessage__c,ItemShippingType__c,
                                         ItemStatusID__c,ItemLevelSupplierName__c,Product2.ProductCode,finalSale__c
                                          from OrderItem where OrderId =: ord[0].Id and Type = 'Order Product'];
        
        List<OrderItemSummary> deliveryOrdItem = [SELECT Id,TotalPrice,TotalTaxAmount from OrderItemSummary where 
                                                  OrderSummaryId =: ordSum[0].Id and Type = 'Delivery Charge'];
        
        Set<Id> proOrdItemIds = new Set<Id>();
        for(OrderItem oItem:productOrdItem){
            proOrdItemIds.add(oItem.Id);
        }
		List<OrderItemTaxLineItem> prodTaxLine = [SELECT Id,Name,Amount,Rate,OrderItemId from OrderItemTaxLineItem 
                                                  where OrderItemId IN : proOrdItemIds];
        //List<OrderItemTaxLineItem> deliveryTaxLine;
        //if(deliveryOrdItem.size() > 0){
            //deliveryTaxLine = [SELECT Amount from OrderItemTaxLineItem 
                                                      //where OrderItemId =: deliveryOrdItem[0].Id];
        //}
        
        
        List<OrderItemAdjustmentLineItem> prodAdjustment = [SELECT Name,Amount,ItemDiscPromoName__c,ItemDiscCouponNo__c,
                                                           ItemDiscNo__c,ItemDiscPromoNo__c,OrderItemId,OrderAdjustmentGroup.Name
                                                            from OrderItemAdjustmentLineItem
                                                           where OrderItemId IN : proOrdItemIds];
        
        List<CardPaymentMethod> crdPay = [SELECT CardType,CardHolderName,ExpiryYear,ExpiryMonth,paypalOrderID__c,
                                         DisplayCardNumber,Payment_Codes__c from CardPaymentMethod where
                                          AccountId =: accId];
        Integer crdPaySize = crdPay.size();
        Integer crdPayLastEleIndex = crdPaySize-1;
        
        List<PaymentGroup> pGroup = [SELECT Id from PaymentGroup where SourceObjectId =: ord[0].Id];
        
        List<PaymentAuthorization> pAuth = [SELECT Amount,Date,authCode__c,requestToken__c,requestId__c
                                           from PaymentAuthorization where PaymentGroupId =: pGroup[0].Id and 
                                           AccountId =: accId];
        String oType = 'pickup';
        if(ordDelGrp[0].OrderDeliveryMethod.Name != null){
            if(ordDelGrp[0].OrderDeliveryMethod.Name == 'Army Post Office' || ordDelGrp[0].OrderDeliveryMethod.Name == 'standard'){
                oType = 'shipping';
            }
        }
        System.debug(ordDelGrp[0].OrderDeliveryMethod.Name);
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();//1
        gen.writeFieldName('ProcessingOptions');
        gen.writeStartObject();//2
        gen.writeBooleanField('UseSubmittedTax', true);
        gen.writeBooleanField('SendEmails', false);
        gen.writeEndObject();//2
        if(ord[0].OrderReferenceNumber != null){
            gen.writeStringField('OrderExternalOrderID', ord[0].OrderReferenceNumber);
        }
        if(ord[0].aptosOrderStatusID__c != null){
            gen.writeNumberField('OrderStatusId', ord[0].aptosOrderStatusID__c);
        }
        if(ord[0].EffectiveDate != null){
            
            gen.writeDateTimeField('OrderDate', ord[0].EffectiveDate);
        }
        //if(ord[0].Type != null){
            gen.writeStringField('OrderType', oType);
        //}
        //if(ord[0].ExternalAffId__c != null){
        //    gen.writeNumberField('ExternalAffId', ord[0].ExternalAffId__c);
        //}
        gen.writeStringField('ExternalAffId', '115');//putting default value for now
        if(ord[0].createdBy__c != null){
            if(ord[0].createdBy__c == 'Store' || ord[0].createdBy__c == 'POS'){
                gen.writeNumberField('OrderAffiliateType', 1);
                ordPaymentId = 4;
            }
            else{
                //gen.writeNumberField('OrderAffiliateType', 2);
            }
        }
        gen.writeNumberField('OrderAffiliateType', 2);//putting default value for now
        if(ordDelGrp[0].DeliverToName != null && oType == 'shipping'){
            gen.writeStringField('OrderContact', ordDelGrp[0].DeliverToName);
        }
        else if(oType == 'pickup' && acc[0].FirstName != null && acc[0].LastName != null){
            gen.writeStringField('OrderContact','Snipes c/o '+acc[0].FirstName+' '+acc[0].LastName);
        }
        if(acc[0].FirstName != null){
            gen.writeStringField('FirstName', acc[0].FirstName);
        }
        if(acc[0].LastName != null){
            gen.writeStringField('LastName', acc[0].LastName);
        }
        if(ordDelGrp[0].DeliverToStreet != null){
            gen.writeStringField('OrderShippingAddress1', ordDelGrp[0].DeliverToStreet);
        }
        
        gen.writeStringField('OrderShippingAddress2', '');
        
        if(ordDelGrp[0].DeliverToCity != null){
            gen.writeStringField('OrderShippingCity', ordDelGrp[0].DeliverToCity);
        }
        if(ordDelGrp[0].DeliverToState != null){
            gen.writeStringField('OrderShippingStateProvince', ordDelGrp[0].DeliverToState);
        }
        if(ordDelGrp[0].DeliverToPostalCode != null){
            gen.writeStringField('OrderShippingZip', ordDelGrp[0].DeliverToPostalCode);
        }
        if(ordDelGrp[0].PhoneNumber != null){
            gen.writeStringField('OrderShippingPhone', ordDelGrp[0].PhoneNumber);
        }
        if(true){
            gen.writeStringField('OrderShippingCountryCode', 'US');//constant for now, will figure out later how to get
            //country code
        }
        if(ordDelGrp[0].DeliverToCountry != null){
            gen.writeStringField('OrderShippingCountryISOCode', 'USA');
            gen.writeStringField('OrderShippingCountry', 'USA');
        }
        if(ord[0].TotalAmount != null){
            gen.writeNumberField('OrderAmount', ordSum[0].TotalAdjustedProductAmount);
        }
        if(ord[0].TotalAdjustedDeliveryAmount != null){
            gen.writeNumberField('OrderAmountShipping', ord[0].TotalAdjustedDeliveryAmount);
        }
        if(ord[0].GrandTotalAmount != null){
            gen.writeNumberField('OrderAmountTotal', ord[0].GrandTotalAmount);
        }
        if(ord[0].TotalTaxAmount != null){
            gen.writeNumberField('OrderAmountTax', ord[0].TotalTaxAmount);
        }
        if(ord[0].TotalAdjustedDeliveryTaxAmount != null){
            gen.writeNumberField('OrderAmountShippingTax', ord[0].TotalAdjustedDeliveryTaxAmount);
        }
        //if(crdPay[crdPayLastEleIndex].Payment_Codes__c != null){
            gen.writeNumberField('OrderPaymentTypeId', ordPaymentId);
        //}
        gen.writeFieldName('OrderCustomer');
        gen.writeStartObject();//3
        if(ord[0].Name != null){
            gen.writeStringField('CustomerName', ord[0].Name);
        }
        if(acc[0].FirstName != null){
            gen.writeStringField('CustomerFirstName', acc[0].FirstName);
        }
        if(acc[0].LastName != null){
            gen.writeStringField('CustomerLastName', acc[0].LastName);
        }
        if(ord[0].BillingStreet != null){
            gen.writeStringField('CustomerAddress1', ord[0].BillingStreet);
        }
        if(true){
            gen.writeStringField('CustomerAddress2', '');
        }
        if(ord[0].BillingCity != null){
            gen.writeStringField('CustomerCity', ord[0].BillingCity);
        }
        if(ord[0].BillingStateCode != null){
            gen.writeStringField('CustomerStateProvince', ord[0].BillingStateCode);
        }
        if(ord[0].BillingPostalCode != null){
            gen.writeStringField('CustomerPostalCode', ord[0].BillingPostalCode);
        }
        if(ord[0].BillingCountry != null && ord[0].BillingCountry == 'United States'){
            gen.writeStringField('CustomerCountry','US');
        }
        if(true){
            gen.writeStringField('CustomerCountryISOCode', 'USA');
        }
        if(ord[0].BillingEmailAddress != null){
            gen.writeStringField('CustomerEmail', ord[0].BillingEmailAddress);
        }
        if(ord[0].BillingPhoneNumber != null){
            gen.writeStringField('CustomerPhone', ord[0].BillingPhoneNumber);
        }
        gen.writeFieldName('CustomerAlternatePayments');
        //gen.writeString('CustomerAlternatePayments');
        gen.writeStartArray();//4
        if(paypalOrderId == ''){
            gen.writeStartObject();//5
        		if(crdPay[crdPayLastEleIndex].CardHolderName != null){
            		gen.writeStringField('PaymentCardName', crdPay[crdPayLastEleIndex].CardHolderName);
        		}
        		if(crdPay[crdPayLastEleIndex].DisplayCardNumber != null){
            		gen.writeStringField('PaymentCardNumber', crdPay[crdPayLastEleIndex].DisplayCardNumber);
        		}
        		if(crdPay[crdPayLastEleIndex].ExpiryMonth != null && crdPay[crdPayLastEleIndex].ExpiryYear != null){
            		gen.writeStringField('PaymentCardExp',crdPay[crdPayLastEleIndex].ExpiryMonth+'/'+crdPay[crdPayLastEleIndex].ExpiryYear);
        		}
        		if(crdPay[crdPayLastEleIndex].CardType != null){
            		gen.writeStringField('PaymentCardType', crdPay[crdPayLastEleIndex].CardType);
        		}
        	gen.writeEndObject();//5
        }
        gen.writeEndArray();//4
        gen.writeEndObject();//3
        gen.writeFieldName('OrderAuths');
        gen.writeStartArray();//6
        gen.writeStartObject();//7
        if(pAuth[0].Date != null){
            //String localTime = pAuth[0].Date.format('yyyy-MM-dd HH:mm:ss', 'EDT');
            String convertedDate = dateFormatter(pAuth[0].Date);
            gen.writeStringField('DateAuthorized', convertedDate);
        }
        if(pAuth[0].Amount != null){
            gen.writeNumberField('AuthAmount', pAuth[0].Amount);
        }
        if(paypalOrderId == ''){
            if(pAuth[0].authCode__c != null){
            	gen.writeStringField('AuthOrderNumber', pAuth[0].authCode__c);
        	}
        	if(pAuth[0].requestId__c != null){
            	gen.writeStringField('CardAuthCode', pAuth[0].requestId__c);
        	}
        	if(pAuth[0].requestToken__c != null){
            	gen.writeStringField('RequestToken', pAuth[0].requestToken__c);
        	}
        	if(pAuth[0].requestId__c != null){
            	gen.writeStringField('RequestID', pAuth[0].requestId__c);
        	}
        }
        else{
            gen.writeStringField('AuthOrderNumber', paypalOrderId);
            gen.writeStringField('CardAuthCode', paypalOrderId);
            gen.writeStringField('RequestToken', '');
            gen.writeStringField('RequestID', '');
        }
        gen.writeEndObject();//7
        gen.writeEndArray();//6
        gen.writeFieldName('OrderGiftCards');
        gen.writeStartArray();//8
        gen.writeEndArray();//8
        //if(crdPay[crdPayLastEleIndex].paypalOrderID__c != null){
            gen.writeStringField('OrderPayPalOrderID', paypalOrderId);
        //}
        
        if(true){
            gen.writeStringField('CustomData1', customData1);
        }
        gen.writeFieldName('OrderItems');
        gen.writeStartArray();//9
        Integer j=0;//for counting tax line
        Integer k=0;//for counting adjustment line
        for(Integer i=0;i<productOrdItem.size();i++){
            gen.writeStartObject();//10
            gen.writeFieldName('ItemProduct');
            gen.writeStartObject();//11
            if(productOrdItem[i].Product2.ProductCode != null){
                //String proParNum = prodTaxLine[i].Name.substringBefore(' -');
                gen.writeStringField('ProductPartNo',productOrdItem[i].Product2.ProductCode);
            }
            gen.writeEndObject();//11
            //if(productOrdItem[i].ItemStatusID__c != null){
                //Integer itemStatus = Integer.valueOf(productOrdItem[i].ItemStatusID__c);
                gen.writeNumberField('ItemStatusId', 4);//setting default value of 4 for now
            //}
            if(productOrdItem[i].UnitPrice != null){
                gen.writeNumberField('ItemPrice', productOrdItem[i].UnitPrice);
            }
            if(productOrdItem[i].Quantity != null){
                gen.writeNumberField('ItemQuantity', productOrdItem[i].Quantity);
            }
            Decimal itemTot = 0;
            if(productOrdItem[i].Quantity != null && productOrdItem[i].UnitPrice != null ){
                itemTot = productOrdItem[i].Quantity*productOrdItem[i].UnitPrice;
                if(prodTaxLine.size()>0 && prodTaxLine[j].OrderItemId == productOrdItem[i].Id && prodTaxLine[j].Amount != null ){
                    itemTot+=prodTaxLine[j].Amount;
                }
                gen.writeNumberField('ItemTotal', itemTot);
            }
            if(i == 0 && deliveryOrdItem.size()>0 && deliveryOrdItem[0].TotalPrice != null){
                gen.writeNumberField('ItemShipping', deliveryOrdItem[0].TotalPrice);
            }
            else{
                gen.writeNumberField('ItemShipping', 0);
            }
            if(i == 0 && deliveryOrdItem.size() >0 && deliveryOrdItem[0].TotalTaxAmount != null  ){
                //System.debug(deliveryTaxLine);
                gen.writeNumberField('ItemShippingTax', deliveryOrdItem[0].TotalTaxAmount);
            }
            else{
                gen.writeNumberField('ItemShippingTax', 0);
            }
            if(prodTaxLine.size()>0 && j<prodTaxLine.size() && prodTaxLine[j].OrderItemId == productOrdItem[i].Id && prodTaxLine[j].Amount != null){
                gen.writeNumberField('ItemTax', prodTaxLine[j].Amount);
            }
            else{
                gen.writeNumberField('ItemTax', 0);
            }
            if(prodTaxLine.size()>0 && j<prodTaxLine.size() && prodTaxLine[j].OrderItemId == productOrdItem[i].Id && productOrdItem[i].UnitPrice != null && prodTaxLine[i].Amount != null &&productOrdItem[i].Quantity != null){
                Decimal tax = prodTaxLine[j].Amount;
                Decimal adjustment = 0;
                Decimal result = 0;
                if(tax > 0){
                    if(prodAdjustment.size() > 0 && k < prodAdjustment.size() && prodAdjustment[k].Amount != null){
                    	adjustment = prodAdjustment[k].Amount;
                	}
                	result = tax.divide((productOrdItem[i].UnitPrice*productOrdItem[i].Quantity + adjustment),18);
                }
                gen.writeNumberField('ItemTaxRate',result);
            }
            else{
                gen.writeNumberField('ItemTaxRate',0);
            }
            if(oType == 'shipping'){
                gen.writeStringField('ItemCustomShipCode', 'UD01');
            }
            if(oType == 'pickup'){
                gen.writeStringField('ItemCustomShipCode', 'LOCPU');
            }
            //if(productOrdItem[i].ItemShippingType__c != null){
                gen.writeStringField('ItemShippingType', 'E');//constant value
            //}
            if(productOrdItem[i].ItemGiftWrap__c != null){
               gen.writeBooleanField('ItemGiftWrap', productOrdItem[i].ItemGiftWrap__c);
            }
            if(productOrdItem[i].ItemGiftMessage__c != null){
                gen.writeStringField('ItemGiftMessage', productOrdItem[i].ItemGiftMessage__c);
            }
            else{
                gen.writeStringField('ItemGiftMessage', '');
            }
            if(prodAdjustment.size() > 0 && k<prodAdjustment.size() && prodAdjustment[k].OrderItemId == productOrdItem[i].Id && prodAdjustment[k].Amount != null){
                gen.writeNumberField('ItemDiscountDetailsTotal', -1*prodAdjustment[k].Amount);
            }
            else{
                gen.writeNumberField('ItemDiscountDetailsTotal', 0);
            }
            gen.writeFieldName('ItemDiscountDetails');
            gen.writeStartArray();//12
            if(prodAdjustment.size() > 0 && k<prodAdjustment.size() && prodAdjustment[k].OrderItemId == productOrdItem[i].Id && prodAdjustment[k].Amount != null && -1*prodAdjustment[k].Amount > 0){
                //System.debug('here');
                gen.writeStartObject();//13
                gen.writeNumberField('ItemDiscAmount', -1*prodAdjustment[k].Amount);
            	if(prodAdjustment[k].Name != null){
                    String discName = prodAdjustment[k].Name.substringAfter(' - ');
                	gen.writeStringField('ItemDiscName', discName);
            	}
            	if(prodAdjustment[k].OrderAdjustmentGroup != null && prodAdjustment[k].OrderAdjustmentGroup.Name != null){
                	gen.writeStringField('ItemDiscPromoName', prodAdjustment[k].OrderAdjustmentGroup.Name);
            	}
            	if(prodAdjustment[k].ItemDiscCouponNo__c != null){
                	gen.writeStringField('ItemDiscCouponNo', prodAdjustment[k].ItemDiscCouponNo__c);
            	}
                else{
                    gen.writeStringField('ItemDiscCouponNo', '');
                }
            	//if(prodAdjustment[k].ItemDiscNo__c != null){
                	gen.writeNumberField('ItemDiscNo', 1);
            	//}
            	//if(prodAdjustment[k].ItemDiscPromoNo__c != null){
                	gen.writeNumberField('ItemDiscPromoNo', 1);
            	//}
            	gen.writeEndObject();//13
            }
            gen.writeEndArray();//12
            gen.writeStringField('OrderItemType',oType);
            if(productOrdItem[i].finalSale__c){
                gen.writeStringField('CustomData1','Final Sale');
            }
            else{
                gen.writeStringField('CustomData1','');
            }
            gen.writeEndObject();//10
            if(j<prodTaxLine.size() && prodTaxLine[j].OrderItemId == productOrdItem[i].Id){
                j++;
            }
            if(k < prodAdjustment.size() && prodAdjustment[k].OrderItemId == productOrdItem[i].Id){
                k++;
            }
        }
        gen.writeEndArray();//9
        if(ord[0].Order_Discount_Details_Total__c != null){
            gen.writeNumberField('OrderDiscountDetailsTotal',-1*ord[0].Order_Discount_Details_Total__c);
        }
        else{
            gen.writeNumberField('OrderDiscountDetailsTotal',0);
        }
        gen.writeEndObject();//1
        
        OutputParameters op = new OutputParameters();
        op.serOutput = gen.getAsString();
        output.add(op);
        return output;
    }
    private static String dateFormatter(DateTime dt){
        String toConvert = dt.year()+'-';
		if(Integer.valueOf(dt.month()) < 10){
    		toConvert+='0'+dt.month()+'-';
		}
		else{
    		toConvert+=dt.month()+'-';
		}
		if(Integer.valueOf(dt.day()) < 10){
    		toConvert+='0'+dt.day()+'T';
		}
		else{
    		toConvert+=dt.day()+'T';
		}
		if(Integer.valueOf(dt.hour()) < 10){
    		toConvert+='0'+dt.hour()+':';
		}
		else{
    		toConvert+=dt.hour()+':';
		}
		if(Integer.valueOf(dt.minute()) < 10){
    		toConvert+='0'+dt.minute()+':';
		}
		else{
    		toConvert+=dt.minute()+':';
		}
		if(Integer.valueOf(dt.second()) < 10){
    		toConvert+='0'+dt.second();
		}
		else{
    		toConvert+=dt.second();
		}
        
        return toConvert;
    }
	public class InputParameters{
        @InvocableVariable(required=true)
    	public String AccountId;
        
        @InvocableVariable(required=true)
    	public String OrderSumNumber;
    }
    public class OutputParameters{
        @InvocableVariable
        public String serOutput;
    }
}