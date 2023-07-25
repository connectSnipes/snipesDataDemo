public class CallCancelOrderItemSummarySubmit {
    public static void run(){
        ConnectApi.ChangeItemInputRepresentation orderItemInputRepresentation = new ConnectApi.ChangeItemInputRepresentation();
    	orderItemInputRepresentation.orderItemSummaryId = '10u55000000Cl15AAC';
        orderItemInputRepresentation.quantity = 2;
        orderItemInputRepresentation.reason = 'Not Satisfied';
        orderItemInputRepresentation.shippingReductionFlag = true;
        
        ConnectApi.ChangeInputRepresentation orderInputRepresentation = new ConnectApi.ChangeInputRepresentation();
        orderInputRepresentation.changeItems = new List<ConnectApi.ChangeItemInputRepresentation>();
        //System.debug(orderInputRepresentation.changeItems);
        orderInputRepresentation.changeItems.add(orderItemInputRepresentation);
        //System.debug(orderInputRepresentation.changeItems);
        //try{
            //ConnectApi.PreviewCancelOutputRepresentation output = ConnectApi.OrderSummary.previewCancel('1Os55000000Chl4CAC',orderInputRepresentation);
        	//System.debug(output);
        //}
        //catch(ConnectApi.ConnectApiException e){
            //System.debug(e.getErrorCode());
        //}
        try{
            ConnectApi.SubmitCancelOutputRepresentation output = ConnectApi.OrderSummary.submitCancel('1Os55000000Chl4CAC',orderInputRepresentation);
        	System.debug(output);
        }
        catch(ConnectApi.ConnectApiException e){
            System.debug(e.getErrorCode());
        }
        
    }
}