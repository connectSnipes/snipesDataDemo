({
    init: function(component, event) {
        var self = this;

        var initAction = component.get("c.sendNotification");
        initAction.setParams({
            sfOrderItemId: component.get("v.orderItemId")
        });

        initAction.setCallback(this, function(initActionResult) {
            var state = initActionResult.getState();

            if(state == "SUCCESS") {
                component.find("notifLib").showToast({
                    variant: "success",
                    header: "Success",
                    message: "Success"
                });
                self.closeModal(component, event);
            } else {
                var notifLib = component.find("notifLib");
                var errors = initActionResult.getError();
                if(errors) {
                    var errorMsg = "Unknown Error.";

                    if(errors[0].message) {
                        errorMsg = errors[0].message;
                    } else if(errors[0].pageErrors) {
                        errorMsg = errors[0].pageErrors[0].message;
                    } else if(errors[0].fieldErrors) {
                        errorMsg = errors[0].fieldErrors[0].message;
                    }

                    notifLib.showNotice({
                        variant: "error",
                        header: "Error",
                        message: errorMsg
                    });
                }

                self.closeModal(component, event);
            }            
        });

        $A.enqueueAction(initAction);
    },
    closeModal: function(component, event) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getEnclosingTabId().then(function(response) {
            workspaceAPI.closeTab({
                tabId: response
            });
        });
    }
})