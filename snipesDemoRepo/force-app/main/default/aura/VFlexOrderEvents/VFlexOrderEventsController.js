({
    onInit: function(component, event, helper) {
        helper.init(component, event);
    },
    onClose: function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getEnclosingTabId().then(function(response) {
            console.log(response);
            workspaceAPI.closeTab({
                tabId: response
            });
        });
    }
})