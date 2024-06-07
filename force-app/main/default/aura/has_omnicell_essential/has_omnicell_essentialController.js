({
  doInit : function(component, event, helper){
    var action = component.get('c.isrendered');
    var rid = component.get("v.recordId");
    var sobj = component.get("v.sobjecttype");
    
      action.setParams({ "key" : rid , "obj" : sobj });
    action.setCallback(this,function(response){
        
        var storeResponse = response.getReturnValue();
        
        if(storeResponse[0]==='true'){
            component.set('v.rendered',true);
        }else{
            component.set('v.rendered',false);
        }
        component.set("v.error", storeResponse[1]);
        
         //console.log(storeResponse);
    });
      $A.enqueueAction(action);
    
      
    }
})