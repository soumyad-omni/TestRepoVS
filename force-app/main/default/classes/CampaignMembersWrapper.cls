public with sharing class CampaignMembersWrapper {


    public Boolean checked{ get; set; }
    public String Status{ get; set;}
    
    public CampaignMember cm { get; set;}
    
    public String memberType{get;set;}
    public String memberStatus{get;set;}
    public String company{get;set;}
    public String title{get;set;}
    public String omniJobTitleCode{get;set;}
    public String leadClassification{get;set;}
    public String leadOwner{get;set;}
    public String prodOpportunity{get;set;}
    public String campaignnotes{get;set;}//Added by sravan for SF-BUG-778
    public String intrestedprd{get;set;}//Added by sravan for SF-BUG-778
    //public string ldOwnerId{get;set;}//Added by sravan for SF-BUG-778
    public String followUpFieldFilter{get;set;}
    public DateTime createdDate{get;set;}
    public DateTime lastModifiedDate{get;set;}
    public Boolean followUpTaskHasBeenAssd{get;set;}
    public String acctName{get;set;}
    public String acctOwner{get;set;}
    public String VP{get;set;}
    public String directManager{get;set;}
    public Id directManagerId{get;set;}
    public String keyAcctManager{get;set;}
    public Id keyAcctManagerId{get;set;}
    public String regionalManager{get;set;}
    public Id regionalManagerId{get;set;}
    public String director{get;set;}
    public Id directorId{get;set;}
    public String insideSalesRep{get;set;}
    public Id insideSalesRepId{get;set;}
    public String salesDevelopmentConsultant{get;set;}
    public Id salesDevConId{get;set;}
    public String IVRep{get;set;}
    public Id IVRepId{get;set;}
    public String perfCenterRep{get;set;}
    public Id perfCenterRepId{get;set;}
    public String country{get;set;}
    public String division{get;set;}
    public String region{get;set;}
    public String territory{get;set;}
    public String worldRegion{get;set;}
    public String acctStatus{get;set;}
    public String facilityType{get;set;}
    public String partnerType{get;set;}
    public Boolean isLeadOwnerIsQueue{get;set;}
    public Boolean isUserActive{get;set;}
    public String fullName{get;set;}
    
    public CampaignMembersWrapper(){
        cm = new CampaignMember();
        checked = false;        
        
    }
    
    public CampaignMembersWrapper(CampaignMember c){
        //
        cm = c;
        checked = false;
        memberType = '';
        memberStatus = '';
        company = '';
        title = '';
        omniJobTitleCode = '';
        leadClassification = '';
        leadOwner = '';
        prodOpportunity = '';
        campaignnotes = '';//Added by sravan for SF-BUG-778
        intrestedprd = '';//Added by sravan for SF-BUG-778
        followUpFieldFilter = '';
        createdDate = null;
        lastModifiedDate = null;
        followUpTaskHasBeenAssd = false;
        acctName = '';
        acctOwner = '';
        VP = '';
        directManager = '';
        directManagerId = null;
        keyAcctManager = '';
        keyAcctManagerId = null;
        regionalManager = '';
        regionalManagerId = null;
        director = '';
        directorId = null;
        insideSalesRep = '';
        insideSalesRepId = null;
        salesDevelopmentConsultant = '';
        salesDevConId = null;
        IVRep = '';
        IVRepId = null;
        perfCenterRep = '';
        perfCenterRepId = null;
        country = '';
        division = '';
        region = '';
        territory = '';
        worldRegion = '';
        acctStatus = '';
        facilityType = '';
        partnerType = '';
        isLeadOwnerIsQueue = False;
        //ldOwnerId = '';//Added by sravan for SF-BUG-778
        isUserActive = True;
        fullName='';
        //
        Map<String,Acct_Team_Roles_for_Followup_Task__c> teamRoles = Acct_Team_Roles_for_Followup_Task__c.getAll();
        Set<String> ActTeamRoleList = teamRoles.keySet();
        Id acctId;
        List<Account> acct = new List<Account>();
        List<Lead> ldList = new List<Lead>();
        //System.Debug('c.Lead.Account__r.Id :- '+c.Lead.Account__r.Id);
        //System.Debug('c.Contact.Account.Id :- '+c.Contact.Account.Id);
        //System.Debug('memberType : '+memberType);
        try{
            if((c.LeadId != null && c.ContactId == null) || memberType =='Lead'){
                //ldList = [select id,OwnerId from Lead where id =: c.Lead.Id ]; //Commented by sravan for sf-bug-778
                
                //if(ldList.size()>0){    //Commented by sravan for sf-bug-778                
                    if(string.valueOf(c.lead.ownerId).startsWith('00G')){ //Added ownerid for 778
                        System.debug('initial value of boolean : '+isLeadOwnerIsQueue);
                        isLeadOwnerIsQueue = True;
                        checked = false;
                        //System.debug('lead owner :'+isLeadOwnerIsQueue);
                    }
                //} //Commented by sravan for sf-bug-778
            } 
            /*if((c.LeadId != null && c.ContactId == null) || memberType =='Lead'){
                acct = [select id from Account where id =: c.Lead.Account__r.Id];
                if(acct.size()>0){
                    acctId = acct[0].id;
                }
            }else if(c.ContactId != null || memberType =='Contact'){
                acct = [select id from Account where id =: c.Contact.Account.Id];
                if(acct.size()>0){
                    acctId = acct[0].id;
                }
            }
            System.Debug('acctId : '+acctId);
            Commented by sravan for 778//List<AccountTeamMember> atm = [select TeamMemberRole, User.Id, User.Name from AccountTeamMember where AccountId =: acctId and TeamMemberRole in: ActTeamRoleList];
            System.Debug('Account Team Members : '+ atm);
            for(AccountTeamMember tMem : atm){*///Commented by sravan for 778
                /*if(tMem.TeamMemberRole == 'Direct Manager'){
                    directManager = tMem.User.Name;
                    directManagerId = tMem.User.Id;
                    //System.Debug('directManagerId : '+directManagerId);
                }else*/ 
                /*if(tMem.TeamMemberRole == System.Label.Key_Account_Manager){Commented by sravan for 778
                    keyAcctManager = tMem.User.Name;
                    keyAcctManagerId = tMem.User.Id;
                }*///Commented by sravan for 778
/*else if(tMem.TeamMemberRole == 'Regional Manager'){
                    regionalManager = tMem.User.Name;
                    regionalManagerId = tMem.User.Id;
                }else if(tMem.TeamMemberRole == 'Director'){
                    director = tMem.User.Name;
                    directorId = tMem.User.Id;
                }*/
            	/*for(AccountTeamMember tMem : atm1){
                    if(tMem.AccountId == acctId){
                	if(tMem.TeamMemberRole == System.Label.Inside_Sales_Rep){
                    	insideSalesRep = tMem.User.Name;
                    	insideSalesRepId = tMem.User.Id;
                	}
                    }
                }*/
/*else if(tMem.TeamMemberRole == 'Sales Development Consultant'){
                    salesDevelopmentConsultant = tMem.User.Name;
                    salesDevConId = tMem.User.Id;
                }*/
                /*else if(tMem.TeamMemberRole == System.Label.IV_Sales_Consultant){Commented by sravan for 778
                    IVRep = tMem.User.Name;
                    IVRepId = tMem.User.Id;
                }*///Commented by sravan for 778
/*else if(tMem.TeamMemberRole == 'Performance Center Rep'){
                    perfCenterRep = tMem.User.Name;
                    perfCenterRepId = tMem.User.Id;
                }*/
                
            //} Commented by sravan for 778
            if(c.ContactId != null || memberType =='Contact'){
                    memberType = 'Contact';//Schema.SObjectType.CampaignMember.getRecordTypeInfosByName().get('Development').getRecordTypeId();
                    memberStatus = c.Status;
                    fullName = c.Contact.FirstName +' '+ c.Contact.LastName;
                	title = c.Contact.Title;
                    omniJobTitleCode = c.Contact.Omnicell_Job_Code__c;
                    //leadClassification = c.Lead_Classification__c;
                    //leadOwner = c.Lead.Owner.Name;
                    prodOpportunity = c.Product_Opportunity__c;
                	campaignnotes = c.Campaign_Notes__c;//Added by sravan for SF-BUG-778
                    followUpFieldFilter = c.Follow_up_Field_Filter__c;
                    createdDate = c.CreatedDate;
                    lastModifiedDate = c.LastModifiedDate;
                    followUpTaskHasBeenAssd = c.Task_Assigned__c;//c.Follow_up_Task_Assigned__c;
                    acctName = c.Contact.Account.Name;
                    acctOwner = c.Contact.Account.Owner.Name;
                    //IBA-4149  VP = c.Contact.Account.VP__c;
                    
                    country = c.Contact.Account.BillingCountry;
                    division = c.Contact.Account.Division_Account__c;
                    region = c.Contact.Account.Region__c;
                    territory = c.Contact.Account.Account_Territory__c;
                    worldRegion = c.Contact.Account.Country_Cluster__c;
                    acctStatus = c.Contact.Account.Account_Status__c;
                    facilityType = c.Contact.Account.Facility_Type__c;
                    partnerType = c.Contact.Account.Partner_Type__c;
                    //System.Debug('c.Contact.Account.Partner_Type__c : '+c.Contact.Account.Partner_Type__c);
                    //System.Debug('partnerType : '+partnerType);
            }else if((c.LeadId != null && c.ContactId == null) || memberType =='Lead'){
                memberType = 'Lead';
                memberStatus = c.Status;
                fullName = c.Lead.FirstName +' '+ c.Lead.LastName;
                company = c.Lead.Company;
                title = c.Lead.Title;
                omniJobTitleCode = c.Lead.Omnicell_Job_Title__c;
                leadClassification = c.Lead_Classification__c;
                leadOwner = c.Lead.Owner.Name;
                //ldOwnerId = c.Lead.Owner.Id;//Added by Sravan for SF-BUG-778
                prodOpportunity = c.Product_Opportunity__c;
                campaignnotes = c.Campaign_Notes__c;//Added by sravan for SF-BUG-778
                intrestedprd = c.Lead.Interested_Productslje__c;//Added by sravan for SF-BUG-778
                followUpFieldFilter = c.Follow_up_Field_Filter__c;
                createdDate = c.CreatedDate;
                lastModifiedDate = c.LastModifiedDate;
                followUpTaskHasBeenAssd = c.Task_Assigned__c;//c.Follow_up_Task_Assigned__c;
                acctName = c.Lead.Account__r.Name;
                acctOwner = c.Lead.Account__r.Owner.Name;
               //IBA-4149   VP = c.Lead.Account__r.VP__c;
                
                country = c.Lead.Account__r.BillingCountry;
                division = c.Lead.Account__r.Division_Account__c;
                region = c.Lead.Account__r.Region__c;
                territory = c.Lead.Account__r.Account_Territory__c;
                worldRegion = c.Lead.Account__r.Country_Cluster__c;
                acctStatus = c.Lead.Account__r.Account_Status__c;
                facilityType = c.Lead.Account__r.Facility_Type__c;
                partnerType = c.Lead.Account__r.Partner_Type__c;
            }
            
            //
            //checked = false;
            //
        }catch(Exception e){
            //System.debug('Excepeion at Line No. : '+e.getLineNumber()+' Exception : '+e.getMessage());
            ErrorLogging.Log(e, 'CampaignMembersWrapper','App');
        }
    }
    
    
    
}

/*public class AccountTeamMembersWrapper{
public AccountTeamMembersWrapper(CampaignMember c, AccountTeamMember a){
Map<String,Acct_Team_Roles_for_Followup_Task__c> teamRoles = Acct_Team_Roles_for_Followup_Task__c.getAll();
List<String> ActTeamRoleList = teamRoles.keySet();
List<Account> acctId;
if(memberType =='Lead'){
acctId = [select id from Account where id =: c.Lead.Account__r.Id];
}else if(memberType =='Contact'){
acctId = [select id from Account where id =: c.Contact.Account.Id];
}
List<AccountTeamMember> atm = [select TeamMemberRole, User.Id from AccountTeamMember where AccountId in: acctId and TeamMemberRole in: ActTeamRoleList];

for(AccountTeamMember tMem : atm){
if(atm.TeamMemberRole == 'Direct Manager'){
directManager = c.Lead.Account__r.AccountTeamMember.User.Name;
}else if(atm.TeamMemberRole == 'Key Account Manager'){
keyAcctManager = c.Lead.Account__r.AccountTeamMember.User.Name;
}else if(atm.TeamMemberRole == 'Regional Manager'){
keyAcctManager = c.Lead.Account__r.AccountTeamMember.User.Name;
}else if(atm.TeamMemberRole == 'Director'){
keyAcctManager = c.Lead.Account__r.AccountTeamMember.User.Name;
}else if(atm.TeamMemberRole == 'Inside Sales'){
keyAcctManager = c.Lead.Account__r.AccountTeamMember.User.Name;
}else if(atm.TeamMemberRole == 'Sales Development Consultant'){
keyAcctManager = c.Lead.Account__r.AccountTeamMember.User.Name;
}else if(atm.TeamMemberRole == 'IV Rep'){
keyAcctManager = c.Lead.Account__r.AccountTeamMember.User.Name;
}else if(atm.TeamMemberRole == 'Performance Center Rep'){
keyAcctManager = c.Lead.Account__r.AccountTeamMember.User.Name;
}

}
}
}*/