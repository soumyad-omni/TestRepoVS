public class ContentDocLinkTriggerHandler implements ITriggerHandler{
    // Allows unit test (or other code) to disable this trigger for the transaction
    public static boolean TriggerDisabled= false;
    public boolean isDisabled;
    
    // Check to see if the trigger has been disabled by either custom setting or code
    public boolean IsDisabled(){
        Trigger_Configuration__c tc = Trigger_Configuration__c.getInstance('ContentDocumentLink');
        if(tc != null) isDisabled= tc.isDisabled__c;
        if(isDisabled == true)
            return true;
        else
            return TriggerDisabled;
    }
    
    //=============================================================================
    // BEFORE INSERT
    //=============================================================================
    public void beforeInsert(List<SObject> newItems){//IBA-6018
        List<ContentDocumentLink> cdlink = new List<ContentDocumentLink>();
        cdlink.addall((List<ContentDocumentLink>)newItems);
        
        list<Restrict_File_Upload__c> restObjList1 = [select name from Restrict_File_Upload__c];
        list<string> restObjList2 = new list<string>();
        for(Restrict_File_Upload__c res:restObjList1){
            restObjList2.add(res.name);
        }
        
        list<File_Share_with_ExternalUser__c> userV1 = [select name from File_Share_with_ExternalUser__c];
        list<string> userV2 = new list<string>();
        for(File_Share_with_ExternalUser__c res:userV1){
            userV2.add(res.name);
        }
        
        list<string> cdList = new list<string>();
        for(ContentDocumentLink att: cdlink){
            cdList.add(att.ContentDocumentId);
        }
        
        list<contentversion> cvList = [SELECT id,ContentDocumentId,title,Tag__c FROM contentversion where ContentDocumentId  =: cdList];
        map<id,contentversion> cvMap = new map<id,contentversion> ();
        
        for(contentversion cv:cvList){
            cvMap.put(cv.ContentDocumentId, cv);
        }
        
        list<contentversion> updateCV = new list<contentversion>();
        
        for(ContentDocumentLink att: cdlink){
            Id pId=att.LinkedEntityId;
            string objectName = String.valueOf(pId.getsobjecttype());
            boolean qfromPrint = false;
            boolean cfromPrint = false;
            boolean hasTag = false;
            
            if(cvMap.containskey(att.ContentDocumentId)){
                contentversion cv = cvMap.get(att.ContentDocumentId);
                string title = cv.title;
                qfromPrint = title.endsWith('.qPrintout.pdf');
                cfromPrint = title.endsWith('.cPrintout.pdf');
                if(cv.Tag__c != null){
                    hasTag = true;
                    if(userV2.contains(cv.Tag__c)){
                        att.Visibility = 'AllUsers';
                    }
                }
            }
            
                        
            if(restObjList2.contains(objectName) && qfromPrint == false && cfromPrint == false && hasTag == false){                
                system.debug('restricted');
                att.adderror('Please use custom Upload button to upload file');
            }else if(qfromPrint == true){
                contentversion cv = cvMap.get(att.ContentDocumentId);
                cv.Tag__c = 'Quote';
                updateCV.add(cv);
            }else if(cfromPrint == true){
                contentversion cv = cvMap.get(att.ContentDocumentId);
                cv.Tag__c = 'Contract';
                updateCV.add(cv);
            }else{
                system.debug('not restricted');
            }            
        }
        
        if(updateCV.size() > 0){
            String jsonString = json.serialize(updateCV);
            updateCVrecord(jsonString);
        }
    }
    //=============================================================================
    // BEFORE DELETE
    //=============================================================================
    public void beforeDelete(Map<Id, SObject> oldItems){
        List<ContentDocumentLink> cdlink = oldItems.values();
        Id pId;
        
        for(ContentDocumentLink att: cdlink){
            //Title=att.Name;
            pId=att.LinkedEntityId;
            
            System.debug('Paretnt Id : '+pId);
        }
        
        List<Contracts__c> c1=[select Id,All_Documents_Attached__c,conga_Agreement_Number__c from Contracts__c where Id=:pId];
        
        List<ContentDocumentLink> cdl = [select LinkedEntityId from ContentDocumentLink where LinkedEntityId =:pId]; 
        System.debug('cdl : '+cdl);
        if(c1.size()>0){
            c1[0].conga_Agreement_Number__c = c1[0].conga_Agreement_Number__c-1;
            if(cdl.size() == 0){
                c1[0].All_Documents_Attached__c = false;
                try{
                    update c1;
                    
                }catch(Exception e){
                    c1[0].addError(e);
                }
            }
        }    
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
        List<ContentDocumentLink> cdlink = newItems.values();
        Id pId;
        
        for(ContentDocumentLink att: cdlink){
            //Title=att.Name;
            pId=att.LinkedEntityId;
            
            System.debug('Paretnt Id : '+pId);
        }
        
        List<Contracts__c> c1=[select Id,conga_Agreement_Number__c from Contracts__c where Id=:pId];
        System.debug('c1 : '+c1);
        List<Contracts__c> c=[select Id,All_Documents_Attached__c,conga_Agreement_Number__c from Contracts__c where Id=:pId];
        System.debug('c : '+c);
        if(c1.size()>0){
            System.debug('Inside c1 if');
            if(c1[0].conga_Agreement_Number__c == null)
                c1[0].conga_Agreement_Number__c = 1;
            c1[0].conga_Agreement_Number__c = c1[0].conga_Agreement_Number__c+1;
            System.debug('c1 agre num : '+c1[0].conga_Agreement_Number__c);
            try{
                update c1;
            }Catch(Exception e){
                c1[0].addError(e);
            }
            System.debug('c1 updated : '+c1);
        }
        //assuming one record is fetched.
        if(c.size()>0){
            System.debug('Inside c if');
            c[0].All_Documents_Attached__c=true;
            c[0].conga_Agreement_Number__c = c1[0].conga_Agreement_Number__c;
            try{
                update c[0];
            }Catch(Exception e){
                c[0].addError(e);
            }
        } 
        
    }
    //=============================================================================
    // AFTER UPDATE
    //=============================================================================
    public void afterUpdate(Map<Id, SObject> oldItems, Map<Id, SObject> newItems){
        
        
    }
    
    @future
    public static void updateCVrecord(string jsonString){
        List<contentversion> updateCV = (List<contentversion>)Json.deserialize(jsonString,List<contentversion>.class);
        update updateCV;
    }
}