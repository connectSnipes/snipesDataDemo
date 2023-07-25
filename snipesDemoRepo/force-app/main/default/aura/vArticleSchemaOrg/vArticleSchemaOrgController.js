({
    onInit: function(component, event, helper) {
        let initAction = component.get("c.getSchemaOrgData");
        initAction.setParams({
            recordId: component.get("v.recordId")
        });

        initAction.setCallback(this, function(initActionResult) {
            let state = initActionResult.getState();

            if(state == "SUCCESS") {
                let schemaMap = initActionResult.getReturnValue();
                let schemaData = JSON.stringify(schemaMap, null, '  ');
                console.log(schemaData);

                schemaData = "<script type='application/ld+json'>" + schemaData + "</script>";
                component.set("v.schemaData", schemaData);

            } else {
                console.log(initActionResult.getError());
            }
        });

        $A.enqueueAction(initAction);
    }
})