public with sharing class CampaignActivityPlanningController {

    //
    private Campaign contextCampaign;
    //
    private List<Task> tsks;
    
    private Id idWhat;
        
    //
    public CampaignActivityPlanningController(ApexPages.StandardController controller) {
        this.contextCampaign = (Campaign)controller.getRecord();
    }
    
    // Getter
    //
    public List<Task> getTsks() {
        //
        tsks = new List<Task>();
        //
        List<Task> tasks = [select Subject, ActivityDate, Priority, Owner.Name, Status, Who.Name, 
                            Id, Description, CreatedBy.Name, LastModifiedBy.Name, CreatedDate, LastModifiedDate  
                from task where whatid = :contextCampaign.id ];   //IBA-4524
        //
        if (tasks.size() > 0) {
            //      
            for (task t : tasks)
            {
                tsks.add(t);
            }
            //      
            return tsks;
            //
        } else {
            return null;
        }
        //
    }

    public List<Task> getTsksFollow() {
        //
        tsks = new List<Task>();
        //
        List<Task> tasks = [select Subject, ActivityDate, Priority, Owner.Name, Status, Who.Name, 
                            Id, Description, CreatedBy.Name, LastModifiedBy.Name, CreatedDate, LastModifiedDate  
                from task where whatid = :contextCampaign.id ];      //IBA-4524
        //
        if (tasks.size() > 0) {
            //      
            for (task t : tasks)
            {
                tsks.add(t);
            }
            //      
            return tsks;
            //
        } else {
            return null;
        }
        //
    }

    // Call New Task
    //
    public PageReference newPlanning() {
    
        String url = null;
        
        //
        //RecordType lstRecType = [Select id from RecordType where name = 'Campaign Task' Limit 1];
        
        // Record Type name is recently changed to Master
        
        RecordType lstRecType = [Select id from RecordType where name = 'Master' Limit 1];
        
        Id recTypeId = lstRecType.Id;

        //
        idWhat = this.contextCampaign.Id;
        
        if (recTypeId != null) {
        
            url = '/00T/e?what_id=' + idWhat + '&retURL=' + idWhat + '&RecordType=' + recTypeId + '&ent=Task';
            //url = '/00T/e?what_id=701E0000000YZRu&retURL=701E0000000YZRu&RecordType=012E0000000dTFw&ent=Task&00Nc0000000b8YY=Planning+Purposes';
    
            PageReference  p = new PageReference(url);
            p.setRedirect(true);
            return p;
        } else
            return null;

    }

    public PageReference assignTasks() {
    
        String url = null;
        //
        // get name
        //
        String theCampaignName = [Select name from campaign where id = :this.contextCampaign.Id].Name;
        //
        // Page Link
        //
        url = '/apex/Campaign_Members_Task_Assign?CampaignId=' + this.contextCampaign.Id + '&CampaignName=' + theCampaignName;
        //
        PageReference  p = new PageReference(url);
        p.setRedirect(true);
        //
        return p;
        //
    }

}