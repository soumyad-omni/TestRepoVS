/**
 * @File Name          : QuoteApprovalProgressController.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 29/5/2020, 9:09:40 pm
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    29/5/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public class QuoteApprovalProgressController {
    @AuraEnabled
    public static List<String> getPendingQueues(Id qaId){
        system.debug(qaid);
        Quote_Approval_Chevron__c qa = [select id,Progress_Pending__c from Quote_Approval_Chevron__c where quote_approval__c =:qaId];
        String[] pendingQueues = new String[]{};
        List<ProcessInstance> pi = [SELECT Id,TargetObjectid, Status,(select id,actor.name from Workitems)
                                        FROM ProcessInstance where TargetObjectId =:qaId and Status = 'pending'];
        if(pi.size()>0){
            for(ProcessInstanceWorkitem wi : pi[0].Workitems){
                pendingQueues.add(wi.actor.name);
            }
            System.debug('Pending Queues : '+pendingQueues);
        }
        if(pendingQueues.size() > 0){
            qa.Progress_Pending__c = 'Pending';
            update qa;
            System.debug('Pending Queues : '+pendingQueues);
            return pendingQueues;
        }
        else
            return null;
    }
    
    @AuraEnabled
    public static void updateAssignedto(Id qaId){
        Quote_Approval__c qa=[SELECT Id,Assigned_to__c,Assigned_to2__c FROM Quote_approval__c WHERE Id =: qaid];
        String[] pendingQueues = new String[]{};
        List<ProcessInstance> pi = [SELECT Id,TargetObjectid, Status,
                                        (select id,actor.name,originalActor.name from Workitems)
                                        FROM ProcessInstance 
                                    WHERE TargetObjectId =:qaId and Status = 'pending'];
        Boolean checkLock=Approval.isLocked(qa.id);
        Boolean next=false;
        Approval.Unlock(qa.id);
        if(pi.size()>0){
            for(ProcessInstanceWorkitem wi : pi[0].Workitems){
                /*if(next!=TRUE){
                    qa.assigned_to__c=wi.OriginalActor.name;
                }
                else if(next=true){
                    qa.assigned_to2__c=wi.OriginalActor.name;
                }*/
                updateQA(next, wi.OriginalActor.name, qa);
                //update qa;
                pendingQueues.add(wi.OriginalActor.name);
            }
            //System.debug('Pending Queues : '+pendingQueues);
        }
        else{
            qa.assigned_to__c='';
            qa.assigned_to2__c='';
        }
        update qa;
        if(checkLock==TRUE){
            //Approval.Lock(qa);
        }
        //System.debug(qa.assigned_to__c+'******************'+qa.assigned_to2__c);
        //update qa;
    }
    
    @AuraEnabled
    public static Map<String,String> getApprovedQueues(Id qaId){
        Quote_Approval_chevron__c qa = [select id,Progress_Approved__c from Quote_Approval_Chevron__c where quote_approval__c =:qaId];
        String[] approvedQueues = new String[]{};
            Map<String,String> approvalQueues = new Map<String,String>();
        for(ProcessInstanceStep PIS:[SELECT OriginalActor.Name,createdDate,ActorId, OriginalActor.Title, StepStatus,ProcessInstance.lastActorId,processinstance.status
                                     FROM ProcessInstanceStep where ProcessInstance.TargetObjectId=:qaId and stepStatus='Approved' order by createdDate asc]){
                                         System.debug(PIS.Processinstance.status); 
                                         //User user = [select Name from User where id=:PIS.ActorId];
                                         //String dateapp = PIS.CreatedDate.format('yyyy-MM-dd');
                                         //String timeapp = PIS.CreatedDate.format('HH:mm:ss');
                                         approvalQueues.put(PIS.CreatedDate.format('yyyy-MM-dd')+' '+PIS.CreatedDate.format('HH:mm:ss'),PIS.OriginalActor.name);
                                         //approvalQueues.put(dateapp+' '+timeapp,user.Name);
                                         //approvedQueues.add(PIS.OriginalActor.name);
                                         System.debug('Qpproved Queues :-------------------'+approvalQueues);
                                     }
        
        /*if(approvedQueues.size() > 0){
qa.Progress_Approved__c = 'Approved';
update qa;
System.debug('Approved Queues : '+approvedQueues);
return approvedQueues;
}
else
return null;*/
        if(approvalQueues.size() > 0){
            /*qa.Progress_Approved__c = 'Approved';
            update qa;
            System.debug('Approved Queues : '+approvalQueues);
            return approvalQueues;*/
            return updateQAProgress(qa, 'Approved', approvalQueues);
        }
        else
            return null;
        
    }
    @AuraEnabled
    public static Map<String,String> getRejectedQueues(Id qaId){
        Quote_Approval_chevron__c qa = [select id,Progress_Rejected__c from Quote_Approval_Chevron__c where quote_approval__c =:qaId];
        String[] rejectedQueues = new String[]{};
            Map<String,String> rejectQueues = new Map<String,String>();
        for(ProcessInstanceStep PIS:[SELECT OriginalActor.Name,createdDate,ActorId, OriginalActor.Title, StepStatus,ProcessInstance.lastActorId,processinstance.status
                                     FROM ProcessInstanceStep where ProcessInstance.TargetObjectId=:qaId and stepStatus='Rejected' order by createdDate asc]){
                                         System.debug(PIS.Processinstance.status);  
                                         //User user = [select Name from User where id=:PIS.ActorId];
                                         //String dateapp = PIS.CreatedDate.format('yyyy-MM-dd');
                                         //String timeapp = PIS.CreatedDate.format('HH:mm:ss');
                                         rejectQueues.put(PIS.CreatedDate.format('yyyy-MM-dd')+' '+PIS.CreatedDate.format('HH:mm:ss'),PIS.OriginalActor.name);
                                         //rejectQueues.put(dateapp+' '+timeapp,user.Name);
                                         //rejectedQueues.add(PIS.OriginalActor.name);
                                     }
        /*  if(rejectedQueues.size() > 0){
qa.Progress_Rejected__c = 'Rejected';
update qa;
System.debug('Rejected Queues : '+rejectedQueues);
return rejectedQueues;
}
else
return null;*/
        if(rejectQueues.size() > 0){
            /*qa.Progress_Rejected__c = 'Rejected';
            update qa;
            System.debug('Rejected Queues : '+rejectQueues);
            return rejectQueues;*/
            return updateQAProgress(qa, 'Rejected', rejectQueues);
        }
        else
            return null;
    }
    @AuraEnabled
    public static List<DateTime> getApprovedDate(Id qaId){
        List<DateTime> approvedDates = new List<DateTime>();
        for(ProcessInstanceStep PIS:[SELECT OriginalActor.Name,createdDate, OriginalActor.Title, StepStatus,ProcessInstance.lastActorId,processinstance.status
                                     FROM ProcessInstanceStep where ProcessInstance.TargetObjectId=:qaId and stepStatus='Approved' order by createdDate desc]){
                                         System.debug(PIS.Processinstance.status);  
                                         approvedDates.add(PIS.CreatedDate);
                                     }
        if(approvedDates.size()>0)
            return approvedDates;
        else
            return null;
    }
    @AuraEnabled
    public static List<String> getQueuesNotStarted(Id qaId){
        Boolean containsqueuename = false;
        String[] nsqueues = new String[]{};
            Quote_Approval__c qa = [select id,Need_Legal_Team_Approval__c,Need_Finance_Team_Approval__c,Need_Operations_Team_Approval__c,Need_CSC_Approval__c,Approval_Progress_Status_Not_Started__c,RecordTypeId,Requires_Deal_Desk_Approval__c,
                                    Requires_Legal_Approval__c,Requires_Legal_Approval_For_Service__c,
                                    Requires_RX_Config_Approval__c,Requires_Sales_Finance_Approval__c,Requires_Tech_Svcs_Approval__c,Requires_Professional_Services__c
                                    from Quote_Approval__c where id =:qaId]; //soumyad added Requires_Professional_Services__c sf-bug-976
        Quote_Approval_chevron__c qac = [select id,Approval_Progress_Status_Not_Started__c from Quote_Approval_Chevron__c where quote_approval__c =:qaId];
            
        System.debug('Recordtype id : -------------'+Schema.SObjectType.Quote_Approval__c.getRecordTypeInfosByName().get('International ADC/VBM Supplement').getRecordTypeId());
        if(qa.RecordTypeId == Schema.SObjectType.Quote_Approval__c.getRecordTypeInfosByName().get('International ADC/VBM Supplement').getRecordTypeId()){
            System.debug('');
            if(qa.Need_CSC_Approval__c == true && !containsQueue('CSC',qaId)){
                if(!rejected('CSC',qaId))
                    nsqueues.add('CSC');
                    //nsqueues.add('Deal Desk');
            }
            if(!containsQueue('Deal',qaId) && !rejected('Deal',qaId))
                nsqueues.add('Deal Desk');
        }
        else if(qa.RecordTypeId == Schema.SObjectType.Quote_Approval__c.getRecordTypeInfosByName().get('PES Inception Order/PA Quote').getRecordTypeId()){
            System.debug('Inside PES Test');
            if(!containsQueue('Deal',qaId) && !rejected('Deal',qaId)){
                nsqueues.add('Deal Desk');
            }
            
            if(qa.Need_Finance_Team_Approval__c == true && !containsQueue('PES Finance',qaId)){
                if(!rejected('PES Finance',qaId))
                    nsqueues.add('PES Finance');
            }
            if(qa.Need_Operations_Team_Approval__c == true && !containsQueue('PES Operations',qaId)){
                if(!rejected('PES Operations',qaId))
                    nsqueues.add('PES Operations');
            }
            if(qa.Need_Legal_Team_Approval__c == true && !containsQueue('Legal',qaId)){
                if(!rejected('Legal',qaId))
                    nsqueues.add('PES Legal');
            }
        }
        else{
            //Boolean test = rejected('Deal',qaId);
            //System.debug('Test:--------------------------------------------------------------------------------'+test);
            
            //IBA-1678
        /*if(qa.Requires_RX_Config_Approval__c == true && !containsQueue('RX',qaId)){
            if(!rejected('RX',qaId))
                nsqueues.add('RX Consultants');
        }*/
        
        
        
        if(qa.Requires_Tech_Svcs_Approval__c == true && !containsQueue('Tech',qaId)){
            if(!rejected('Tech',qaId))
                nsqueues.add('Tech Services');
            
        }
        if(qa.Requires_Sales_Finance_Approval__c == true && !containsQueue('Sales',qaId)){
            if(!rejected('Sales',qaId))
                nsqueues.add('Sales Finance');
            
        }
        if(qa.Requires_Deal_Desk_Approval__c == true && !containsQueue('Deal',qaId)){
            if(!rejected('Deal',qaId))
                nsqueues.add('Deal Desk');
            
        }
        if((qa.Requires_Legal_Approval__c == true || qa.Requires_Legal_Approval_For_Service__c == true) && !containsQueue('Legal',qaId)){
            if(!rejected('Legal',qaId))
                nsqueues.add('Legal');
            
        }
       /* if(qa.Requires_Legal_Approval_For_Service__c == true && !containsQueue('Legal',qaId)){
            if(!rejected('Legal',qaId))
                nsqueues.add('Legal');
            
        } */
        //soumyad sf-bug-976 start
        if(qa.Requires_Professional_Services__c == true && !containsQueue('Professional',qaId)){
            if(!rejected('Professional',qaId))
                nsqueues.add('Professional');
            
        } 
        //soumyad sf-bug-976 end
        }
       /* if(!containsQueue('Booking',qaId)){
            nsqueues.add('Booking Team');
        }*/
        
        qac.Approval_Progress_Status_Not_Started__c = 'Not_Started'; 
        update qac;
        System.debug('Not Started Queues : '+nsqueues);
        return nsqueues;
    }
    
    public static Boolean containsQueue(String queue,Id qaId){
        System.debug('Queue Not Started : '+queue);
        String[] ProcessQueues = new String[]{};
            for(ProcessInstanceStep PIS:[SELECT OriginalActor.Name,createdDate,ActorId, OriginalActor.Title, StepStatus,ProcessInstance.lastActorId,processinstance.status
                                         FROM ProcessInstanceStep where ProcessInstance.TargetObjectId=:qaId and stepStatus = 'Approved' order by createdDate desc]){
                                             System.debug(PIS.Processinstance.status);
                                             ProcessQueues.add(PIS.OriginalActor.Name);
                                         }
        for(ProcessInstanceStep PIS:[SELECT OriginalActor.Name,createdDate,ActorId, OriginalActor.Title, StepStatus,ProcessInstance.lastActorId,processinstance.status
                                     FROM ProcessInstanceStep where ProcessInstance.TargetObjectId=:qaId and stepStatus = 'Rejected' order by createdDate desc]){
                                         System.debug(PIS.Processinstance.status);
                                         ProcessQueues.add(PIS.OriginalActor.Name);
                                     }
        List<ProcessInstance> pi = [SELECT Id,TargetObjectid, Status,(select id,actor.name from Workitems)
                                    FROM ProcessInstance where TargetObjectId =:qaId and Status = 'pending'];
        if(pi.size()>0){
            for(ProcessInstanceWorkitem wi : pi[0].Workitems){
                ProcessQueues.add(wi.actor.name);
            }
        }
        System.debug('Process Queues : '+ProcessQueues+' '+ProcessQueues.size());
        if(processQueues.size()>0){
            for(String queueName : ProcessQueues){
                System.debug('Queue Name : --------'+queueName);
                if(queueName.contains(queue)){
                    System.debug('Inside if');
                    return true;
                    
                }
            }
        }
        return false;
    }
    public static Boolean rejected(String queue,Id qaId){
        System.debug('Inside rejected Function');
        String[] ProcessQueues = new String[]{};
            for(ProcessInstanceStep PIS:[SELECT OriginalActor.Name,createdDate,ActorId, OriginalActor.Title, StepStatus,ProcessInstance.lastActorId,processinstance.status
                                         FROM ProcessInstanceStep where ProcessInstance.TargetObjectId=:qaId and stepStatus = 'Rejected' order by createdDate desc]){
                                             System.debug(PIS.Processinstance.status);
                                             ProcessQueues.add(PIS.OriginalActor.Name);
                                         }
        System.debug('Rejected Queues :------------------------------------'+processQueues);
        for(ProcessInstanceStep PIS:[SELECT OriginalActor.Name,createdDate,ActorId, OriginalActor.Title, StepStatus,ProcessInstance.lastActorId,processinstance.status
                                     FROM ProcessInstanceStep where ProcessInstance.TargetObjectId=:qaId and stepStatus = 'NoResponse' order by createdDate desc]){
                                         System.debug(PIS.Processinstance.status);
                                         ProcessQueues.add(PIS.OriginalActor.Name);
                                     }
        System.debug('No Response Queues :------------------------------------'+processQueues);
        for(ProcessInstanceStep PIS:[SELECT OriginalActor.Name,createdDate,ActorId, OriginalActor.Title, StepStatus,ProcessInstance.lastActorId,processinstance.status
                                     FROM ProcessInstanceStep where ProcessInstance.TargetObjectId=:qaId and stepStatus = 'Approved' order by createdDate desc]){
                                         System.debug(PIS.Processinstance.status);
                                         ProcessQueues.add(PIS.OriginalActor.Name);
                                     }
        System.debug('Approved Queues :------------------------------------'+processQueues);
        if(processQueues.size()>0){
            for(String queueName : ProcessQueues){
                System.debug('Rejected Queue Name : --------'+queueName);
                if(queueName.contains(queue))
                    return true;
            }
        }
        return false;
        
    }
    @AuraEnabled
    public static String getChRecordId(Id qId){
        List<Quote_Approval_Chevron__c> qacList = [select id from Quote_Approval_Chevron__c where quote_approval__c = :qId];
        if(qacList.size() > 0 && qacList[0] != null && qacList[0].id != null)
        {
            return qacList[0].id;
        }else
            return 'noid';
    }
    
    public static void updateQA(Boolean next, String name, Quote_Approval__c qa){
        if(next!=TRUE){
            qa.assigned_to__c=name;
        }
        else if(next=true){
            qa.assigned_to2__c=name;
        }
    }
    
    public static Map<String,String> updateQAProgress(Quote_Approval_chevron__c qa, String progress, Map<String,String> mapToReturn){
        if(progress == 'Rejected')//Added by Sourav Das SF-BUG-794 Start
        {
            qa.Progress_Rejected__c = progress;
        }
        if(progress == 'Approved')
        {
            qa.Progress_Approved__c = progress;
        }					      //Added by Sourav Das SF-BUG-794 End
        update qa;
        return mapToReturn;
    }
}