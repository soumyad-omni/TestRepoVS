public class CampaignCloneController {
    Campaign newCamp = new Campaign();
    Campaign cmp{get;set;}
    public Date strtdate{get;set;}
    public Date Enddate{get;set;}
    Date ClonedStartDate{get; set;}
    public boolean isSetDefault;
    public boolean isSetResponded;
    public String cmpid = ApexPages.currentPage().getParameters().get('Id');
    public CampaignCloneController(ApexPages.StandardController controller){
        this.cmp = (Campaign)controller.getRecord();
        //List<Campaign> cmpList = [select id,startDate from Campaign where id =:cmpid limit 1];
        cmp.Template__c = false;
        cmp.ParentId = null;
        cmp.Top_Level_Parent__c = null;
        //strtdate = cmpList[0].StartDate;
        strtdate = null;
        enddate = null;
        ClonedStartDate= null;
    
    }
    public pageReference updatetoplevelparent(){
        cmp.Top_Level_Parent__c = cmp.ParentId;
        return null;
    }
    public PageReference save(){
        newCamp.Name = cmp.Name;
        newCamp.Short_Name__c = cmp.Short_Name__c;
        newCamp.ParentId = cmp.ParentId;
        newCamp.Top_Level_Parent__c = cmp.Top_Level_Parent__c;
        //newCamp.StartDate = cmp.StartDate;
        //newCamp.StartDate = ClonedStartDate;
        newCamp.StartDate = StrtDate;
        //newCamp.EndDate = cmp.EndDate;
         newCamp.EndDate = enddate;
        // newCamp.Project_Owner__c = cmp.Project_Owner__c;
        newCamp.Campaign_Approval__c = cmp.Campaign_Approval__c;
        newCamp.Market_Portfolio_Segment__c = cmp.Market_Portfolio_Segment__c;
        newCamp.Type = cmp.Type;
        newCamp.Campaign_sub_type__c = cmp.Campaign_sub_type__c;
        newCamp.Status = cmp.Status;
        newCamp.Campaign_Region__c = cmp.Campaign_Region__c;
        newCamp.IsActive = cmp.IsActive;
        newCamp.Template__c = false;
        newCamp.Description = cmp.Description;
        newCamp.Campaign_Approval__c = cmp.Campaign_Approval__c;
        /*newCamp.Add_to_Calendar__c = cmp.Add_to_Calendar__c;
        newCamp.Calendar_Start_Date__c = cmp.Calendar_Start_Date__c;
        newCamp.Calendar_End_Date__c = cmp.Calendar_End_Date__c;
        newCamp.ExpectedResponse = cmp.ExpectedResponse;
        newCamp.HierarchyNumberOfCampaignMembers__c = cmp.HierarchyNumberOfCampaignMembers__c;*/
        //newCamp.ActualCost = cmp.ActualCost;
        newCamp.BudgetedCost = cmp.BudgetedCost;
        //newCamp.RSVP_Date__c = cmp.RSVP_Date__c;
        newCamp.Target_Initiative__c = cmp.Target_Initiative__c;
        newCamp.Target_Initiative_2__c = cmp.Target_Initiative_2__c;
        newCamp.Strategic_Initiative__c = cmp.Strategic_Initiative__c;
        newCamp.RecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Campaign').getRecordTypeId();
        
        try{
            insert newCamp;
            List<campaignMemberStatus> cms = [SELECT Id, IsDeleted, CampaignId, Label, SortOrder, IsDefault, HasResponded FROM 
                                              CampaignMemberStatus where CampaignId=:cmpid];
											  
			List<campaignMemberStatus> cmsWith2Statuses = [SELECT Id, IsDeleted, CampaignId, Label, SortOrder, IsDefault, HasResponded FROM 
                                             CampaignMemberStatus where CampaignId=:cmpid and (Label=:System.Label.Responded OR Label=:System.Label.Sent)];
            
            List<campaignMemberStatus> cmsToInsert = new List<campaignMemberStatus>();


            if(cmsWith2Statuses.size()==0 || cmsWith2Statuses.size()==1){
                isSetDefault = true;
                isSetResponded = true;
            }else{
                isSetDefault = false;
                isSetResponded = false;
            }
            
			for(campaignMemberStatus c:cms){
                System.Debug('c.Label :: '+c.Label);
                campaignMemberStatus cm = new campaignMemberStatus();
                if(c.Label != System.Label.Responded && c.Label != System.Label.Sent){
                    if(isSetDefault && cm.IsDefault){
                    	cm.IsDefault = true;
                        isSetDefault = false;
                    }else{
                        cm.IsDefault = c.IsDefault;
                    }
                    if(isSetResponded && cm.HasResponded){
                    	cm.HasResponded = true;
                    }else{
                        cm.HasResponded = c.HasResponded;
                    }
                    cm.Label = c.Label;
                    cm.CampaignId = newCamp.Id;
                    cmsToInsert.add(cm);
                }
            }
            
			System.debug('cmsToInsert : '+cmsToInsert);
            insert cmsToInsert;
            
            List<campaignMemberStatus> cmsToDeleteSent = [SELECT Id, IsDeleted, CampaignId, Label, SortOrder, IsDefault, HasResponded FROM 
                                              CampaignMemberStatus where CampaignId=:newCamp.Id and Label=:System.Label.Sent];
            
            List<campaignMemberStatus> cmsToDeleteResp = [SELECT Id, IsDeleted, CampaignId, Label, SortOrder, IsDefault, HasResponded FROM 
                                              CampaignMemberStatus where CampaignId=:newCamp.Id and Label=:System.Label.Responded];
            
            
            //System.debug('cmsToDelete :: '+cmsToDelete);
            
            if(cmsWith2Statuses.size()==0){
                if(cmsToDeleteResp.size()>0){
                    delete cmsToDeleteResp;
                }if(cmsToDeleteSent.size()>0){
                    delete cmsToDeleteSent;
                }
            }else{            
                for(campaignMemberStatus c:cmsWith2Statuses){
                        if(c.Label==System.Label.Sent){
                            if(cmsWith2Statuses.size()!=2 && cmsToDeleteResp.size()>0){    //SF-BUG-743 Fix by RJ
                                try{
                                    delete cmsToDeleteResp;
                                }catch(DMLException e1){
                                    System.debug('line no.'+e1.getLineNumber());
                                }  
                            }
                        }if(c.Label==System.Label.Responded){
                            if(cmsWith2Statuses.size()!=2 && cmsToDeleteSent.size()>0){
                                try{
                                    delete cmsToDeleteSent;
                                }catch(DMLException e2){
                                    System.debug('line no.'+e2.getLineNumber());
                                }
                            }
                        }
                }
            }
            PageReference pr = new PageReference('/'+newCamp.id);
            pr.setRedirect(true);
            return pr;
        }
        catch(DMLException e) { 
            ApexPages.addMessages(e);
            ErrorLogging.Log(e, 'CampaignCloneController','App');
            System.debug('line no.'+e.getLineNumber());
            return null; 
        }
    }
    
}