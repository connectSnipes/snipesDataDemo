@RestResource(UrlMapping='/simplr/getOrderByOrderId')
global with sharing class SimplrGetOrderByOrderIdAction {
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

    global class SimplrGetOrderByOrderIdResponse {
        global List<SimplrOrder> orderObjectList;
    }

    @HttpPost
    global static SimplrGetOrderByOrderIdResponse action(String orderId) {
        RestResponse res = RestContext.response;
        try {
            SimplrGetOrderByOrderIdResponse response = new SimplrGetOrderByOrderIdResponse();
            List<Order> orderObjList = SimplrQueries.getOrderByOrderId(orderId);
            List<SimplrOrder> simplrOrderObjList = new List<SimplrOrder>();

            if (!orderObjList.isEmpty()) {
                Order orderObj = orderObjList.get(0);
                List<OrderItem> orderItemsObjList = SimplrQueries.getOrderItems(orderId);
                User userObj = SimplrQueries.getUserById(orderObj.OwnerId);
                Account accountObj = SimplrQueries.getAccountById(orderObj.AccountId);
                Contract contractObj = SimplrQueries.getContractById(orderObj.ContractId);
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

            response.orderObjectList = simplrOrderObjList;

            return response;
        } catch (Exception e) {
            System.debug(e.getStackTraceString());
            SimplrUtil.setErrorResponse(res, e.getMessage(), 500);
            return null;
        }
    }
}