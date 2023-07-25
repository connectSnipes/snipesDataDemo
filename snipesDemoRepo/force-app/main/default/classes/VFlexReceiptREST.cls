@RestResource(urlMapping='/v1/receipt')
global without sharing class VFlexReceiptREST {
    @HttpPost
    global static void doPost() {
        APILog__c lg = new APILog__c(Status__c = 'Success', Source__c = 'Receipts');

        PutResponse res = new PutResponse();
        RestRequest restReq = RestContext.request;
        RestResponse restResp = RestContext.response;

        try {
            String req = restReq.requestBody.toString();
            System.debug(req);

            lg.Request__c = req;

            VFlexDigitalReceipt receipt = (VFlexDigitalReceipt)JSON.deserialize(req, VFlexDigitalReceipt.class);
            receipt.upsertOrder(loadProducts(receipt));
            restResp.statusCode = 200;
        } catch(Exception e) {
            System.debug(e.getStackTraceString());
            restResp.statusCode = 200;
            res.errorCode = e.getTypeName();
            res.message = e.getMessage();

            lg.Status__c = 'Error';
        } finally {
            String strResponse = JSON.serialize(res, false);
            restResp.responseBody = Blob.valueOf(strResponse);

            lg.Response__c = strResponse;
            insert lg;
        }
    }

    @TestVisible
    private class PutResponse {
        public String errorCode;
        public String message;
    }

    private static Map<String, PricebookEntry> loadProducts(VFlexDigitalReceipt digitalReceipt) {
        Map<String, PricebookEntry> res = new Map<String, PricebookEntry>();
        Set<String> productSkus = new Set<String>();

        VFlexDigitalReceipt.FlexReceipt receipt = digitalReceipt.data.apiRequest.data.receipt;

        for(VFlexDigitalReceipt.TransactionItem item : receipt.transactionItem) {
            productSkus.add(item.itemSKUNumber);
        }

        for(PricebookEntry prod : [select Id, Product2Id, Product2.ProductCode 
            from PricebookEntry
            where Pricebook2.IsStandard = true
            and Product2.ProductCode in :productSkus]) {
            
            res.put(prod.Product2.ProductCode, prod);
        }

        Map<String, Product2> productsToInsert = new Map<String, Product2>();

        List<PricebookEntry> pbsToInsert = new List<PricebookEntry>();
        Map<String, Decimal> priceMap = new Map<String, Decimal>();

        for(VFlexDigitalReceipt.TransactionItem item : receipt.transactionItem) {
            String sku = item.itemSKUNumber;
            Product2 prod = new Product2(
                IsActive = true,
                Name = item.itemName,
                ProductCode = sku
            );

            if(item.itemDescription != null) {
                prod.Description = item.itemDescription.value;

                if(item.itemDescription.value != null) {
                    List<String> itemDescList = new List<String>();

                    
                    if(item.itemDescription.value.contains('&#124;')) {
                        itemDescList = item.itemDescription.value.split('&#124;');
                    } else if(item.itemDescription.value.contains('|')) {
                        itemDescList = item.itemDescription.value.split('\\|');
                    }

                    if(itemDescList.size() == 3) {
                        prod.Size__c = itemDescList[2];
                    }
                }
            }

            if(res.containsKey(sku)) {
                prod.Id = res.get(sku).Product2Id;
            } else {
                priceMap.put(sku, item.itemPrice.value);
            }
            productsToInsert.put(sku, prod);
            
        }

        if(productsToInsert.size() > 0) {
            upsert productsToInsert.values();
        }

        for(String sku : productsToInsert.keySet()) {
            Product2 prod = productsToInsert.get(sku);
            Decimal price = priceMap.get(sku);

            if(prod != null && price != null) {
                PricebookEntry pbEnt = new PricebookEntry(
                    Pricebook2Id = VOrder.PRICEBOOK_ID,
                    Product2Id = prod.Id,
                    IsActive = true,
                    UnitPrice = price
                );
                pbsToInsert.add(pbEnt);
                res.put(sku, pbEnt);
            }
        }

        if(pbsToInsert.size() > 0) {
            insert pbsToInsert;
        }

        return res;
    }
}