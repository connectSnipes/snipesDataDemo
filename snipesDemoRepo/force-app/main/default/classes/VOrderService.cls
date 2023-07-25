public inherited sharing class VOrderService {
    public String lastRequest { get; set; }
    public String lastResponse { get; set; }

    public APILog__c lg { get; private set; }
    public void processOrders(List<VOrder> orderList, IOrderSuccessHandler successHandler, IOrderErrorHandler errorHandler) {
        lg = new APILog__c(Status__c = 'Success', Source__c = 'E-Commerce');

        if(orderList.size() > 10) {
            throw new VOrder.OrderException('Exceeded max limit of 10 orders in a single transaction.');
        }
        
        Savepoint sp = Database.setSavepoint();
        try {
            Map<String, PricebookEntry> productMap = loadProducts(orderList);

            for(VOrder order : orderList) {
                Savepoint sp2 = Database.setSavepoint();
                try {
                    order.upsertOrder(productMap);
                    successHandler.handleSuccess(order.OrderNumber);
                } catch(Exception e) {
                    System.debug(e.getStackTraceString());
                    Database.rollback(sp2);

                    errorHandler.handleError(e.getTypeName(), e.getMessage());
                    lg.Status__c = 'Error';
                }
            }
        } catch(Exception e) {
            System.debug(e.getStackTraceString());
            Database.rollback(sp);
            throw e;
        }
    }

    public void commitLogs() {
        if(lg != null) {
            lg.Request__c = lastRequest;
            lg.Response__c = lastResponse;

            insert lg;
        }
    }

  
    private Map<String, PricebookEntry> loadProducts(List<VOrder> orderList) {
        Map<String, PricebookEntry> res = new Map<String, PricebookEntry>();
        Set<String> productSkus = new Set<String>();

        for(VOrder order : orderList) {
            if(order.OrderShippingAddresses != null) {
                List<VOrder.SnipesItem> itemList = order.OrderShippingAddresses[0].Items;

                for(VOrder.SnipesItem item : itemList) {
                    if(item.ItemProduct == null) continue;

                    String sku = item.ItemProduct.OptionSKU;
                    productSkus.add(sku);
                }
            }
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

        for(VOrder order : orderList) {
            if(order.OrderShippingAddresses != null) {
                List<VOrder.SnipesItem> itemList = order.OrderShippingAddresses[0].Items;

                for(VOrder.SnipesItem item : itemList) {
                    if(item.ItemProduct == null) continue;
                    
                    String sku = item.ItemProduct.OptionSKU;
                    Product2 prod = new Product2(
                        IsActive = true,
                        Name = item.ItemProduct.ProductName,
                        ProductCode = sku
                    );

                    if(res.containsKey(sku)) {
                        prod.Id = res.get(sku).Product2Id;
                    } else {
                        priceMap.put(sku, item.ItemPrice);
                    }

                    if(item.ItemProduct.OptionText != null) {
                        List<String> options = item.ItemProduct.OptionText.split(';');

                        for(String o : options) {
                            if(o.contains('Size=')) {
                                prod.Size__c = o.substring(5);
                                break;
                            }
                        }
                    }

                    productsToInsert.put(sku, prod);    
                }
            }
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