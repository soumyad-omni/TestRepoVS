({
    /*
     * This method is being called from init event
     * to fetch all available recordTypes
     * */

    fetchListOfRecordTypes: function(component, event, helper) {
        var action = component.get("c.fetchRecordTypeValues");
		//pass the object name here for which you want
        //to fetch record types
        action.setParams({
            "objectName" : "Task" 
        });
        
        action.setCallback(this, function(response) {
            var mapOfRecordTypes = response.getReturnValue();
            component.set("v.mapOfRecordType", mapOfRecordTypes);

            var recordTypeList = [];
            //Creating recordTypeList from retrieved Map
            for(var key in mapOfRecordTypes){
                recordTypeList.push(mapOfRecordTypes[key]);
            }
           // var size = recordTypeList.length;
             //   console.log('size : '+size)
            
            if(recordTypeList.length == 0 || recordTypeList.length == 1){//Object does not have any record types
                //Close Quick Action Modal here
                helper.closeModal();
                
                //Calling CreateRecord modal here without providing recordTypeId
                helper.showCreateRecordModal(component, "", "Task");
            } else{
            component.set("v.lstOfRecordType", recordTypeList);
               // component.set("v.size",size);
            }
        });
        $A.enqueueAction(action);
    },
    
    /*
     * This method will be called when "Next" button is clicked
     * It finds the recordTypeId from selected recordTypeName
     * and passes same value to helper to create a record
     * */
    createRecord: function(component, event, helper, sObjectRecord) {
        var selectedRecordTypeName = component.find("recordTypePickList").get("v.value");
        
        
        if(selectedRecordTypeName != ""){
            var selectedRecordTypeMap = component.get("v.mapOfRecordType");
            var selectedRecordTypeId;
            
            //finding selected recordTypeId from recordTypeName
            for(var key in selectedRecordTypeMap){
                if(selectedRecordTypeName == selectedRecordTypeMap[key]){
                    selectedRecordTypeId = key;//match found, set value in selectedRecordTypeId variable
                    break;
                }
            }
            
            //Close Quick Action Modal here
            helper.closeModal();
            
            //Calling CreateRecord modal here without providing recordTypeId
            helper.showCreateRecordModal(component, selectedRecordTypeId, "Task");
        } else{
            alert('You did not select any record type');
        }
    },
    
    /*
     * closing quickAction modal window
     * */
    closeModal : function(component, event, helper){
        helper.closeModal();
    }
})