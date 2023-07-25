@RestResource(UrlMapping='/simplr/getOrdersByEmail')
global with sharing class SimplrGetOrdersByEmailAction {
    global class SimplrOrderItemProduct {
        global OrderItem orderItemObject;
        global Product2 productObject;
    }

    global class SimplrOrder {
        global Order orderObject;
        global User userObject;
        global Account accountObject;
        global Contract contractObject;
        global List<SimplrOrderItemProduct> orderItemProductObjectList;
    }

    global class SimplrGetOrdersByEmailResponse {
        global List<SimplrOrder> orderObjectList;
    }

    @HttpPost
    global static SimplrGetOrdersByEmailResponse action(String email) {
        RestResponse res = RestContext.response;
        try {
            SimplrGetOrdersByEmailResponse response = new SimplrGetOrdersByEmailResponse();
            List<SimplrOrder> simplrOrderObjList = new List<SimplrOrder>();
            List<User> userObjList = SimplrQueries.getUserByEmail(email);

            if (!userObjList.isEmpty()) {
                User userObj = userObjList.get(0);
                List<Order> ordersObjList = SimplrQueries.getUserOrders(userObj.Id);

                for (Order orderObj : ordersObjList) {
                    Account accountObj = SimplrQueries.getAccountById(orderObj.AccountId);
                    Contract contractObj = SimplrQueries.getContractById(orderObj.ContractId);
                    List<OrderItem> orderItemsObjList = SimplrQueries.getOrderItems(orderObj.Id);

                    List<SimplrOrderItemProduct> orderItemProductObjList = new List<SimplrOrderItemProduct>();

                    for (OrderItem orderItemObj : orderItemsObjList) {
                        Product2 productObj = SimplrQueries.getProduct2ById(orderItemObj.Product2Id);
                        
                        SimplrOrderItemProduct orderItemProduct = new SimplrOrderItemProduct();
                        orderItemProduct.orderItemObject = orderItemObj;
                        orderItemProduct.productObject = productObj;

                        orderItemProductObjList.add(orderItemProduct);
                    }

                    SimplrOrder simplrOrderObj = new SimplrOrder();
                    simplrOrderObj.orderObject = orderObj;
                    simplrOrderObj.userObject = userObj;
                    simplrOrderObj.accountObject = accountObj;
                    simplrOrderObj.contractObject = contractObj;
                    simplrOrderObj.orderItemProductObjectList = orderItemProductObjList;

                    simplrOrderObjList.add(simplrOrderObj);
                }
            }

            response.orderObjectList = simplrOrderObjList;

            return response;
        } catch (Exception e) {
            System.debug(e.getStackTraceString());
            SimplrUtil.setErrorResponse(res, e.getMessage(), 500);
            return null;
        }
    }
}