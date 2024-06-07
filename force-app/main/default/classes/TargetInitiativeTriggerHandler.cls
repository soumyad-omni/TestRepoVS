public with sharing class TargetInitiativeTriggerHandler {
    //constructor
    public TargetInitiativeTriggerHandler() {
    } 
    
    public void beforeInsert (Target_Initiative_Account__c[] triggerListNew, Target_Initiative_Account__c[] triggerListOld) {  
        
        Set<Id> setOfInitiatives = new Set<Id>();
        Set<String> setOfTargetIntiativeName=new Set<String>();
        
        for(Target_Initiative_Account__c ta: triggerListNew) {
            setOfInitiatives.add(ta.target_initiative__c);
            setOfTargetIntiativeName.add(ta.Target_Initiative_Name__c);
        }
        // get a list of all accounts assigned to each Target_Initiative__c
        list<Target_Initiative_Account__c> listOfAccounts = [select Target_Initiative__c, account__c from 
                                                             Target_Initiative_Account__c where Target_Initiative__c = : setOfInitiatives];   
        if (listOfAccounts.size() > 0)  {
            // get a map of target initiative id to account list                                           
            map<Id, list<Id>> idToAccountMap = new map<Id,list<Id>>();
            for(Target_Initiative_Account__c t : listOfAccounts)
            {
                List<Id> tempList = idToAccountMap.get(t.target_initiative__c);
                if( tempList == null ) {
                    tempList = new List<Id>();
                }
                tempList.add(t.account__c);   
                idToAccountMap.put(t.target_initiative__c, tempList);
            }                   
            //system.debug('Account list ' + idToAccountMap);
            
            Set<Id> setOfAccounts = new Set<Id>();
            list<Id> accountList = new list<id>();
            
            // make sure there isnt a duplicate account 
            for(Target_Initiative_Account__c ta: triggerListNew) {
                
                // get list of accounts already associated
                accountList = idToAccountMap.get(ta.target_initiative__c);
                setOfAccounts.addAll(accountList);
                if (setOfAccounts.Contains(ta.account__c)){
                    ta.addError('Cannot add this account. It has already been added to the Target Initiative.');    
                }
            }
        }   
    }
    //IBA-1748 Pabitra
    public void afterInsert (Target_Initiative_Account__c[] triggerListNew, Target_Initiative_Account__c[] triggerListOld) {        
        // IBA-3712 UpdateParentAndChildHierarchy(triggerListNew);
    }   //end IBA-1748 Pabitra 
    
    public void beforeUpdate (Target_Initiative_Account__c[] triggerListNew, Target_Initiative_Account__c[] triggerListOld) {  
    }
    //Start IBA-1748 Pabitra
    public void afterDelete(Target_Initiative_Account__c[] triggerListOld){
                 // IBA-3712 deleteParentAndChildHierarchy(triggerListOld);
    }//end IBA-1748 Pabitra
    //start IBA-1748 Pabitra
    /*public  void deleteParentAndChildHierarchy(Target_Initiative_Account__c[] triggerListOld){
        try{ IBA-3712
    }*/
    //start IBA-1748 Pabitra
    //Utility function to convert Set<String> to String
    public static String setToString(Set<String> setStr){
        String conStr='';
        for(String str:setStr){
            conStr+=str+';';
        }
        if(conStr.length()>0)  {  
            conStr = conStr.substring(0, conStr.length()-1);
        }
        return conStr;
    }//END IBA-1748 Pabitra
    void UpdateParentAndChildHierarchy(Target_Initiative_Account__c[] targetIniNew){
        
        Set<Id> targetIniAccountIds = new Set<Id>();
        for(Target_Initiative_Account__c ta: targetIniNew) {
            if(ta.target_initiative__c!=null)
                targetIniAccountIds.add(ta.Id);
        } 
        System.enqueueJob(new TiAccountAddQueue(targetIniAccountIds));
    }
    //start IBA-1748 Pabitra
    /*   void UpdateParentAndChildHierarchy(Target_Initiative_Account__c[] targetIniNew)
{
try{
Set<Id> setOfTargetInitiatives=new Set<Id>();
Set<Id> targetIniAccountIds = new Set<Id>();
String initiativeName;

for(Target_Initiative_Account__c ta: targetIniNew) {
setOfTargetInitiatives.add(ta.target_initiative__c);
targetIniAccountIds.add(ta.Account__c);
initiativeName=ta.Target_Initiative_Name__c;
} 
System.debug('Ti Account'+targetIniAccountIds+' targetIni Id '+setOfTargetInitiatives);
List<Target_Initiative__c> tiList = [Select Id, Name,Type_of_account_propagation__c from Target_Initiative__c 
where Id in:setOfTargetInitiatives and Use_for_segmentation__c = true];

Set<String> targetInitiativeAccSet = new Set<String>();

String propagationType;
for(Target_Initiative__c tI: tiList){
if(tI.Type_of_account_propagation__c=='Apply to entire hierarchy'){
propagationType = 'Apply to entire hierarchy';
}
if(tI.Type_of_account_propagation__c=='Apply to Parent and immediate children'){
propagationType = 'Apply to Parent and immediate children';
}
if(tI.Type_of_account_propagation__c=='Apply to individual account'){
propagationType = 'Apply to individual account';
}
targetInitiativeAccSet.add(tI.Id);
}

// Map<Id,Account> accountMap = [SELECT Id,Top_Level_CaseSafeID__c,ParentId,External_Data__c From Account 
//                                                   where Id in :targetIniAccountIds]);
Set<Id> tgAcIds = new Set<Id>(targetIniAccountIds);
List<External_Data__c> exDataList = [SELECT Id,AccountID__c FROM External_Data__c WHERE AccountID__c IN :targetIniAccountIds];
Set<Id> exAcKeys = new Set<Id>();
for (External_Data__c exdt :exDataList)
exAcKeys.add(exdt.AccountID__c);

for (Id exAcId:exAcKeys){
if(tgAcIds.contains(exAcId))
tgAcIds.remove(exAcId);
}            
//System.debug ('accountMap ' +accountMap);
List<External_Data__c> extDataListInsert = new List<External_Data__c>();
for (Id acctId:tgAcIds)  {
extDataListInsert.add(new External_Data__c(AccountID__c=acctId));
}

if(!extDataListInsert.isEmpty()){           
insert extDataListInsert;         
}

List<External_Data__c> extDataList= [SELECT Id,AccountID__c,Account_Segment__c,Own_Segment__c,isTiSegmentChanged__c FROM 
External_Data__c WHERE AccountID__c in :targetIniAccountIds];          
Map<Id,External_Data__c> extDataMap = new Map<Id,External_Data__c>();
for (External_Data__c exDt:extDataList){
extDataMap.put(exDt.AccountID__c,exDt);       
}

Map<Id,Account> updateParentAccount = new Map<id,Account>();

Map<Id,External_Data__c> updateExtDataSegmentMap = new Map<Id,External_Data__c>();        

if(targetInitiativeAccSet.size()>0){
for(Target_Initiative_Account__c tg : targetIniNew){   

//System.debug('target ini'+tg.Target_Initiative_Name__c+'tg account '+tg.Account__c);               
External_Data__c extData=new External_Data__c();   
if(extDataMap.get(tg.Account__c)!= null){
extData=extDataMap.get(tg.Account__c);
}  
if(updateExtDataSegmentMap.get(tg.Account__c)!= null){
extData=updateExtDataSegmentMap.get(tg.Account__c);    
}
if(extData.Account_Segment__c == null){
extData.Account_Segment__c = tg.Target_Initiative_Name__c;                        
}
else{
Set<String> segementSet = new Set<String>();
segementSet.addAll(extData.Account_Segment__c.split(';'));
if(!segementSet.contains(tg.Target_Initiative_Name__c)){
extData.Account_Segment__c+=';'+tg.Target_Initiative_Name__c;
}
}  

if(extData.Own_Segment__c==null){
extData.Own_Segment__c =  tg.Target_Initiative_Name__c;
}
else {
Set<String> segementSet = new Set<String>();
segementSet.addAll(extData.Own_Segment__c.split(';'));
if(!segementSet.contains(tg.Target_Initiative_Name__c)){
extData.Own_Segment__c +=';'+tg.Target_Initiative_Name__c;
}
} 
extData.isTiSegmentChanged__c = true;
updateExtDataSegmentMap.put(extData.AccountID__c,extData);  
}
}

if(updateExtDataSegmentMap!=null && !updateExtDataSegmentMap.isEmpty()) {
ExternalDataTriggerHandler.TriggerDisabled= true;  
update updateExtDataSegmentMap.values();
}          

System.debug('Ti Account Ids '+targetIniAccountIds+'initiativeName '+initiativeName+'P Type '+propagationType);
if(targetInitiativeAccSet.size()>0 && (propagationType=='Apply to entire hierarchy' || 
propagationType=='Apply to Parent and immediate children')){
System.enqueueJob(new TargetInitiativeChildUpdate(targetIniAccountIds,initiativeName,propagationType));
}

} catch (Exception exc){
System.debug('Ti exception'+exc); 
throw exc;
}
}//END IBA-1748 Pabitra
//start IBA-1748 Pabitra
*/   
    /*@future
    public static void  deleteAllChildTopAccounts(Id accId,String targetIniName,String propagationType){
        IBA-3712
    }//End IBA-1748 Pabitra*/
    
    public static void createTargetInitiativesAuditRecords(list<Target_Initiative_Account__c> targetInitiativeAccounts)
    {
        list<Target_Initiatives_Audit__c> targetInitiativeAudits = new list<Target_Initiatives_Audit__c>();
        for(Target_Initiative_Account__c tia : targetInitiativeAccounts)
        {
            Target_Initiatives_Audit__c auditRec = new Target_Initiatives_Audit__c();
            auditRec.Account__c = tia.Account__c;
            auditRec.Target_Initiative__c = tia.Target_Initiative__c;
            if(Trigger.isInsert)
                auditRec.Action__c = 'Insert';
            else if(Trigger.isDelete)
                auditRec.Action__c = 'Delete';
            else if(Trigger.isUndelete)
                auditRec.Action__c = 'Undelete';
            targetInitiativeAudits.add(auditRec);
        }
        insert targetInitiativeAudits;
    }
}