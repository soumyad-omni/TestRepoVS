public class QuoteApprovalAssignToFuture {
    
    @future
    Public static Void AssignToQueue(Set<id> setId)
    {
        List<ProcessInstance> pi = [SELECT Id,TargetObjectid, Status,(select id,actor.name,originalActor.name from Workitems)
                                        FROM ProcessInstance WHERE TargetObjectId =: setId and Status = 'pending'];
        
        System.debug('////'+pi);
        System.debug('----'+pi.size());
        List<Quote_Approval__c> qapListAT = [Select id,Assigned_To__c,Status__c From Quote_Approval__c Where id =: setId and Status__c = 'Waiting Approval'];
        List<ProcessInstanceWorkitem> wi = new List<ProcessInstanceWorkitem>();
        if(pi.size()>0)
        {
            wi = pi[0].Workitems;
            System.debug('******'+wi[0].OriginalActor.name);
            System.debug('******'+wi);

        }
        String term = '';
        System.debug('****'+wi.size());
        Integer i = 1;
			
        for(ProcessInstanceWorkitem wis: wi)
        {
                
                if(i == 1)
                {
                    System.debug('******'+term);
                    term = term + wis.OriginalActor.name;
                    System.debug('******'+term);
                    i = i+1;
                }
                else
                {
                        System.debug('******'+term);
                        term = term +','+ wis.OriginalActor.name;
                        System.debug('******'+term);
                        i = i+1;
                }
        }
        //For Additional Quote Approval
       	List<Additional_Quote_Approval__c> aqapList = [SELECT Id, Approval_Status__c, Assigned_To__c, Quote_Approval__c FROM Additional_Quote_Approval__c WHERE Quote_Approval__c =: setId and Approval_Status__c = 'Waiting'];
        System.debug('****'+aqapList.size());
        Set<Id> aqapIds = new Set<Id>();
        for(Additional_Quote_Approval__c qa: aqapList){
            aqapIds.add(qa.Id);
        }
        List<ProcessInstance> aqapPi = new List<ProcessInstance>();
        if(aqapList.size()>0)
        {
            aqapPi = [SELECT Id,TargetObjectid, Status,(select id,actor.name,originalActor.name from Workitems)
                                            FROM ProcessInstance WHERE TargetObjectId IN : aqapIds and Status = 'pending'];
        } 
        List<ProcessInstanceWorkitem> aqapwi = new List<ProcessInstanceWorkitem>();
        String term2 = '';
        Integer j = 0;
        Integer k = 1;
        List<String> AssName = new List<String>();
        if(aqapPi.size()>0)
        {
            for(ProcessInstance p: aqapPi)
            {
                aqapwi.add(p.Workitems);
            }
            //aqapwi = aqapPi[0].Workitems;
            System.debug('******'+aqapwi[0].OriginalActor.name);
            System.debug('******'+aqapwi);

        }
        for(ProcessInstanceWorkitem aqapwis: aqapwi)
        {
            AssName.add(aqapwis.OriginalActor.name);
        }
        
            for(Additional_Quote_Approval__c qa: aqapList)
            {
                qa.Assigned_To__c = AssName[j];
                System.debug('****'+AssName[j]);
                j=j+1;
            }
                AdditionalQuoteApprovalTriggerHandler.TriggerDisabled = true;
                update aqapList;
                AdditionalQuoteApprovalTriggerHandler.TriggerDisabled = false;
    
            
        for(String st : AssName)
        {
            if(k == 1)
                    {
                        
                        term2 = term2 + st;
                        System.debug('******'+term2);
                        k = k+1;
                    }
                    else
                    {
                            System.debug('******'+term2);
                            term2 = term2 +','+ st;
                            System.debug('******'+term2);
                            k = k+1;
                    }
        }
        
        if(term2.length()>1)
        {
            term = term2+','+term;
        }
        if(qapListAT.size()>0)
        {
                if(qapListAT[0].Status__c == 'Waiting Approval')
                {
                    QuoteApprovalTriggerHandler.TriggerDisabled = true;
                    if(qapListAT[0].Assigned_To__c!= term)
                        {
                            qapListAT[0].Assigned_To__c = term;
                            qapListAT[0].Flag__c = False;
                            System.debug('******'+term);
                            update qapListAT;
                        }
                    QuoteApprovalTriggerHandler.TriggerDisabled = false;
                }
        }
    }

}