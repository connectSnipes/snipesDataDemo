({
    init: function(component, event) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getEnclosingTabId().then(function(response) {
            console.log(response);
            workspaceAPI.setTabLabel({
                tabId: response, 
                label: "Order Events"
            });
        });

        component.set("v.columns", [
            {label: "Event Type", fieldName: "eventType", type: "text" },
            {label: "Carrier", fieldName: "carrier", type: "text" },
            {label: "Tracking Number", fieldName: "trackingNumber", type: "text" },
            {label: "Tracking Location", fieldName: "trackingLocation", type: "text" },
            {label: "Status", fieldName: "status", type: "text" },
            {label: "Status Detail", fieldName: "statusDetail", type: "text" },
            {label: "Est. Delivery Date", fieldName: "estDeliveryDate", type: "date", typeAttributes: { year: "numeric", month: "2-digit", day: "2-digit", hour: "2-digit", minute: "2-digit" } },
            {label: "Carrier Date", fieldName: "carrierDate", type: "date", typeAttributes: { year: "numeric", month: "2-digit", day: "2-digit", hour: "2-digit", minute: "2-digit" } },
            {label: "Request Date", fieldName: "requestDate", type: "date", typeAttributes: { year: "numeric", month: "2-digit", day: "2-digit", hour: "2-digit", minute: "2-digit" } }
        ]);

        var orderEventsAction = component.get("c.getEvents");
        orderEventsAction.setParams({
            orderId: component.get("v.orderId")
        });

        orderEventsAction.setCallback(this, function(orderEventsActionResult) {
            var state = orderEventsActionResult.getState();
            console.log(state);
            if(state === "SUCCESS") {
                var data = orderEventsActionResult.getReturnValue();
                component.set("v.data", data);
            }
        });

        $A.enqueueAction(orderEventsAction);
    }
})