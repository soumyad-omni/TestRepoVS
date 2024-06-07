({
   
    doInit : function(component, event, helper){
    var action = component.get('c.isrendered');
    
    action.setParams({ "key" : component.get("v.recordId") });
    action.setCallback(this,function(result){
        component.set('v.rendered',result.getReturnValue());
         console.log(result.getReturnValue());
    });
      $A.enqueueAction(action);
              
    },
    openModel: function(component, event, helper) {
      
      component.set("v.isOpen", true);
        var rid = component.get("v.recordId");
        
		var save_action = component.get("c.updateCheck");
    	//save_action.setParams({key : rid});
        save_action.setCallback(component,
        function(response) {
            var state = response.getState();
            if (state === 'SUCCESS'){
                $A.get('e.force:refreshView').fire();
            } else {
                 
            }
        }
    	);
        $A.enqueueAction(save_action);
        let button = event.getSource();
    button.set('v.disabled',true);
      
   },
 
   closeModel: function(component, event, helper) {
      var rid = component.get("v.recordId");
        
		var save_action = component.get("c.update2");
    	save_action.setParams({key : rid});
        save_action.setCallback(component,
        function(response) {
            var state = response.getState();
            if (state === 'SUCCESS'){
                $A.get('e.force:refreshView').fire();
            } else {
                 
            }
        }
    	);
        $A.enqueueAction(save_action);  
       //alert('closing');
      component.set("v.isOpen", false);
   },
 
   likenClose: function(component, event, helper) {
      
      var rid = component.get("v.recordId");
        var comments = component.find("comments").get("v.value");
       
       //alert('***'+typeof(comments));
		var save_action = component.get("c.update1");
    	save_action.setParams({
            key : rid,
            cmnt : comments
            });
        save_action.setCallback(component,
        function(response) {
            var state = response.getState();
            if (state === 'SUCCESS'){
                $A.get('e.force:refreshView').fire();
            } else {
                 
            }
        }
        
    	);
        $A.enqueueAction(save_action);
       
      component.set("v.isOpen", false);
       component.set("v.isOpen1", true);
   },
    closeModel1: function(component, event, helper) {
      var rid = component.get("v.recordId");
        
		var save_action = component.get("c.update2");
    	//save_action.setParams({key : rid});
        save_action.setCallback(component,
        function(response) {
            var state = response.getState();
            if (state === 'SUCCESS'){
                $A.get('e.force:refreshView').fire();
            } else {
                 
            }
        }
    	);
        $A.enqueueAction(save_action);  
       //alert('closing');
      component.set("v.isOpen1", false);
   }
})