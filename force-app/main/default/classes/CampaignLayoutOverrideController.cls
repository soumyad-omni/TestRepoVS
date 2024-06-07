public class CampaignLayoutOverrideController {
    
    @AuraEnabled 
    public static Id getCurrentUser(){
        return userInfo.getUserId();
    }
    
    //Added below method for SF-BUG-871 by sravan on 20 FEB 2020
    @AuraEnabled 
    public static String getReportUrl(Id campid){
        List<Campaign> camp = [select id from campaign where ParentId =: campid];
        String ids = '';
        if(camp.size()>0){
        for(campaign c : camp){
            ids = ids+c.id+',';
        }
        }
        ids = ids+campid;
        String url = '';
        view_all_campaign_mem_report__c vcmr = view_all_campaign_mem_report__c.getInstance('view_all_campaign_mem_report_url');
        url = vcmr.report_url__c+ids;
        return url;
    }
    public static List<CampaignShare> getIds(Id campId){
        //System.debug(campId);
        List<CampaignShare> s = [select id,userorgroupid,RowCause from campaignshare where campaignId =: campId ];
        //and Rowcause='Manual'                            
        System.debug('CampShare : '+ s[0].userorgroupid);
        return s;
    }
    @AuraEnabled
    public static Boolean getStatus(Id campId){
        Boolean status;
        List<Id> groupids = new List<Id>();
        List<Id> userids = new List<Id>();
        List<CampaignShare> campShare = getIds(campId);
        map<id,Group> Roleid= new map<id,Group>();
        Map<String, profiles__c> profiles = profiles__c.getAll();
        User currentUser = [select id,name,profile.name from User where id =: userInfo.getUserId() ];
        if(profiles.containsKey(currentUser.profile.name)){
            status=true;
        }
        
        for(CampaignShare cmp : campShare){
            if(cmp.UserOrGroupId.getSObjectType() != Schema.User.SObjectType){
                groupids.add(cmp.UserOrGroupId);
            }
            else{
                userids.add(cmp.UserOrGroupId);
                //System.debug('Userids :' );
            }
        }
        for(ID ids : groupids){
            List<GroupMember> groupmembers = [select userorgroupid from GroupMember where GroupId =: ids];
            for(GroupMember g : groupmembers){
                if(g.UserOrGroupId.getSObjectType() == Schema.User.SObjectType){
                    userids.add(g.UserOrGroupId);
                }
            }
            for( Group g :[Select RelatedId From Group where id = :ids]){
                Roleid.put(g.RelatedId,g);
            }
        }
        for(user  u :[Select id, name From User u where u.UserRoleId  = :Roleid.keyset() and UserRoleid != null]){
            Userids.add(u.Id);      
        }
        for(Id user : userids){
            if(user == currentUser.Id)
                status = True;
        }
        return status;
    }   
    
}