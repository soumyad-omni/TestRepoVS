public class AttachmentTriggerHandler implements ITriggerHandler{

    public static boolean TriggerDisabled= false;
    public boolean isDisabled;
    
    public boolean IsDisabled(){
        Trigger_Configuration__c tc = Trigger_Configuration__c.getInstance('Attachment');
        if(tc != null) isDisabled= tc.isDisabled__c;
        if(isDisabled == true)
            return true;
        else
            return TriggerDisabled;
    }
    
    //=============================================================================
    // BEFORE INSERT
    //=============================================================================
    public void beforeInsert(List<SObject> newItems){
        List<Attachment> cdlink = new List<Attachment>();
        cdlink.addall((List<Attachment>)newItems);
        
        list<Restrict_File_Upload__c> restObjList1 = [select name from Restrict_File_Upload__c];
        list<string> restObjList2 = new list<string>();
        for(Restrict_File_Upload__c res:restObjList1){
            restObjList2.add(res.name);
        }
        
        for(Attachment att: cdlink){
            Id pId=att.ParentId;
            string objectName = String.valueOf(pId.getsobjecttype());
            
            boolean hasTag = false;
            string title = att.Name;  
            boolean fromSummSh = title.endsWith('.SummarySheet.docx');
            
            if(restObjList2.contains(objectName) && fromSummSh == false){                
                system.debug('restricted');
                att.adderror('Please use custom Upload button to upload file');
            }else if(fromSummSh == true){
                system.debug('not restricted');
            }else{
                system.debug('not restricted');
            }            
        }
    }
    
    //=============================================================================
    // BEFORE DELETE
    //=============================================================================
    public void beforeDelete(Map<Id, SObject> oldItems){
          
    }
    //=============================================================================
    // BEFORE UPDATE
    //=============================================================================
    public void beforeUpdate(Map<Id, SObject> oldItems, Map<Id, SObject> newItems){
        
        
    }
    //=============================================================================
    // AFTER DELETE
    //=============================================================================
    public void afterDelete(Map<Id, SObject> oldItems){
        
    }
    //=============================================================================
    // AFTER UNDELETE
    //=============================================================================
    public void afterUndelete(Map<Id, SObject> oldItems){
        
    }
    //=============================================================================
    // AFTER INSERT
    //=============================================================================
    public void afterInsert(Map<Id, SObject> newItems){
        List<Attachment> cdlink = new List<Attachment>();
        cdlink.addall((List<Attachment>)newItems.values());
        
        list<Restrict_File_Upload__c> restObjList1 = [select name from Restrict_File_Upload__c];
        list<string> restObjList2 = new list<string>();
        for(Restrict_File_Upload__c res:restObjList1){
            restObjList2.add(res.name);
        }
        list<Agreement_Tag__c> tagInsertList = new list<Agreement_Tag__c>();
        
        for(Attachment att: cdlink){
            Id pId=att.ParentId;
            string objectName = String.valueOf(pId.getsobjecttype());
            
            boolean hasTag = false;
            string title = att.Name;  
            boolean fromSummSh = title.endsWith('.SummarySheet.docx');
            if(fromSummSh == true){
                Agreement_Tag__c tag = new Agreement_Tag__c(Parent_Id__c = att.id, Tag__c = 'Quote');
                tagInsertList.add(tag);
            }           
        }
        
        if(tagInsertList.size() > 0){
            insert tagInsertList;
        }
        
    }
    //=============================================================================
    // AFTER UPDATE
    //=============================================================================
    public void afterUpdate(Map<Id, SObject> oldItems, Map<Id, SObject> newItems){
        
        
    }
}