({
	getTaskHistoryDetailsHelper : function(component) {
		var thList = component.get("c.getTaskHistory");
        thList.setParams
        ({
            taskId: component.get("v.recordId")
        });
        
        thList.setCallback(this, function(data){
            component.set("v.TaskHistoryList", data.getReturnValue());
        });
        $A.enqueueAction(thList);
	}
})