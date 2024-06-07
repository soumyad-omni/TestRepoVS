/**
 * @Description		   : When any TI is added,this class responsible for updating External Data object segment information based on
 * TargetInitiative account, target initiative name and propagation type (TLP/Parent).
 * @File Name          : TargetInitiativeChildUpdate.cls
 * @Author             : Pabitra Tripathy
**/
public class TargetInitiativeChildUpdate implements Queueable {
    Set<Id> tiAccId;
    String targetInitiaveName;
    Boolean applyToTLP;
    String propagationType;
    
    public TargetInitiativeChildUpdate(Set<Id> tiAccId,String targetIniName,String propagationType){
        this.tiAccId = tiAccId;
        this.targetInitiaveName = targetIniName;
        this.propagationType = propagationType;
    }
    
    public void execute(QueueableContext context){
        try{
            List<Account> accDetails=[SELECT Id,Top_Level_CaseSafeID__c,ParentId,External_Data__c From Account WHERE Id IN :tiAccId];
            Set<Id> topLevelAccountIds = new Set<Id>();
            Set<Id> parentAcctIds=new Set<Id>();
            Map<Id,External_Data__c> extDtMap = new Map<Id,External_Data__c>();
            for(Account ac : accDetails){ 
                if(propagationType=='Apply to entire hierarchy'){
                    topLevelAccountIds.add(ac.Top_Level_CaseSafeID__c);
                }
                else if(propagationType=='Apply to Parent and immediate Children'){
                    parentAcctIds.add(ac.Id);
                }
            }
            System.debug('Ti tiAccId '+tiAccId+' ParentAc '+parentAcctIds+' TopLevelParent '+topLevelAccountIds);
            
            List<Account> accListChild=new List<Account>();
            if(propagationType=='Apply to entire hierarchy' && topLevelAccountIds.size()>0)
                accListChild = [Select Id,External_Data__c  From Account Where Top_Level_CaseSafeID__c IN :topLevelAccountIds];
            else if(propagationType=='Apply to Parent and immediate Children' && parentAcctIds.size()>0){
                accListChild = [Select Id,External_Data__c  From Account Where ParentId IN :parentAcctIds];
            }
            
            System.debug('Ti accid '+tiAccId+' accListChild size '+accListChild.size());
            
            Set<Id> accIds=new Set<Id>();
            for(Account ac:accListChild){
                accIds.add(ac.Id);
                if(ac.External_Data__c==null){
                    if(extDtMap.get(ac.Id)==null){
                        extDtMap.put(ac.Id, new External_Data__c(AccountID__c=ac.Id));
                    }
                }
            }
            if(extDtMap!=null && !extDtMap.isEmpty()){
                insert extDtMap.values();
            }
            
            List<External_Data__c> extDataList= [SELECT Id,AccountID__c,Account_Segment__c,Own_Segment__c,isTiSegmentChanged__c  
                                                 FROM External_Data__c WHERE AccountID__c in :accIds];          
            System.debug('Ti extData List size'+extDataList.size());
            Map<Id,External_Data__c> extDataMap = new Map<Id,External_Data__c>();
            for (External_Data__c exDt:extDataList){
                extDataMap.put(exDt.AccountID__c,exDt);       
            }
            List<External_Data__c> extDataUpdate = new List<External_Data__c>();  
            for (Account childAc:accListChild){
                External_Data__c uExtDt = new External_Data__c();
                if(extDataMap.get(childAc.Id)!=null){
                    uExtDt = extDataMap.get(childAc.Id);
                }
                if(uExtDt.Account_Segment__c == null){
                    uExtDt.Account_Segment__c = targetInitiaveName;
                }
                else{
                    Set<String> segementSet = new Set<String>();
                    segementSet.addAll(uExtDt.Account_Segment__c.split(';'));
                    if(!segementSet.contains(targetInitiaveName)){
                        uExtDt.Account_Segment__c +=';'+targetInitiaveName;
                    }
                }  
                uExtDt.isTiSegmentChanged__c = true;
                extDataUpdate.add(uExtDt);
            }
            if(extDataUpdate!=null && !extDataUpdate.isEmpty()){ 
                ExternalDataTriggerHandler.TriggerDisabled= true;  
                update extDataUpdate;
            }
        }catch(Exception exc){
            System.debug('Ti ChildUpdate Exception '+exc);
            throw exc;
        }
    }
}