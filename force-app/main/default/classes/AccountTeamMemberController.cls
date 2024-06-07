public class AccountTeamMemberController {
    
    public List<AccountTeamMember> atmList {get; set;}
    public Id accountid {get;set;}
    public String LoggedInuserid{get;set;}
    public String LoggedInuserProfileid{get;set;}
    Public String AccountOwner {get;set;}
    Public List<Account__c> Admin {get;set;}
    Public Boolean ownerusertrue {get;set;}
    //public List<Account> selected{get;set;}
    public String SelectedId{get; set; }
    public AccountTeamMemberController(ApexPages.StandardController controller) {
        accountid =controller.getRecord().Id;
        LoggedInuserid= Userinfo.getUserId();
        LoggedInuserProfileid= UserInfo.getProfileId().Substring(0,15);
        system.debug(LoggedInuserProfileid);
        
        
        Account acc = (Account) controller.getRecord();
        
        atmList = [SELECT Id, AccountAccessLevel, AccountId, Account.Name,Account.OwnerId,ContactAccessLevel, TeamMemberRole,UserId, User.Name,OpportunityAccessLevel  FROM AccountTeamMember where AccountId =: acc.Id];
        
        
        AccountOwner =[select ownerid from account where Id=: acc.Id].ownerid;
        Admin=[select Profile_Id__c from Account__c where Profile_Id__c = :LoggedInuserProfileid];
        system.debug(Admin);
        if(Admin.size()>0)
        {
            ownerusertrue=true;
        }
        else{
            ownerusertrue=false;
        }
        
        
    }   
    public PageReference deleteMember()
    {
        PageReference pr = new PageReference('/'+accountid);
        pr.setRedirect(true);
        return pr;
        /*System.debug('Inside Delete Member');
        
        System.debug('Member Id 1234 : '+SelectedId);
        if (SelectedId == null) {
            
            return pr;
        }
        else{    
            System.debug('Member Id : '+SelectedId);
            
            AccountTeamMember tobeDeleted = null;
            for(AccountTeamMember atm : atmList)
                if (atm.Id == SelectedId) {
                    tobeDeleted = atm;
                    
                    break;
                }
            if (tobeDeleted != null) {
                //Added by Venu Kukkapalli to delete opportunity TeamMember as part of SF-BUG-266
                deleteOptyTeam(tobeDeleted);
                Delete tobeDeleted; 
            }
            
            return pr;  
        }*/
    }
    
    public void deleteOptyTeam(AccountTeamMember atm){
      /*  List<OpportunityTeamMember> otmDeleteList = new List<OpportunityTeamMember>();
        Account acc= [SELECT Id, OwnerId FROM Account WHERE Id =: atm.AccountId];
        Boolean flagCheck;
        flagCheck = True;
        if(flagCheck==True)
            flagCheck= False;
        if(flagCheck== False)
            flagCheck = True;
        flagCheck = False;
        List<OpportunityTeamMember> otmList = new List<OpportunityTeamMember>();
        List<Opportunity> optyList =[SELECT Id, AccountId, CustomerType__c,IV_Product_Line__c,Performance_Center_Product_Line__c, (SELECT Id, OpportunityId, UserId, TeamMemberRole FROM OpportunityTeamMembers) FROM Opportunity WHERE stageName != '6 Closed Won' AND stageName !='7 Closed Lost' AND AccountId=:atm.AccountId]; 
        for(Opportunity opp : optyList){
            for(OpportunityTeamMember otm:opp.OpportunityTeamMembers){
                if(atm.UserId == otm.UserId && atm.TeamMemberRole == otm.TeamMemberRole && !otmDeleteList.contains(otm))
                    otmDeleteList.add(otm);
            }
            if(acc.OwnerId == atm.UserId){
                OpportunityTeamMember otm = new OpportunityTeamMember();
                otm.UserId = atm.userId;
                otm.TeamMemberRole = Label.OppTeamPopulate5;
                otm.OpportunityId = opp.id;
                if(!otmList.contains(otm))
                    otmList.add(otm);
            }
        }
        Boolean check;
        check = false;
        if(check == false)
            check = true;
        if(check == true)
            check = False;
        check = True;
        try{
            if(otmDeleteList.size()>0){
                Set<OpportunityTeamMember> otmSet = new Set<OpportunityTeamMember>();
                otmSet.addAll(otmDeleteList);
                List<OpportunityTeamMember> uniqOtmList = new List<OpportunityTeamMember>();
                uniqOtmList.addAll(otmSet);
                delete uniqOtmList;
            }
            if(otmList.size()>0){
                Set<OpportunityTeamMember> otmSet = new Set<OpportunityTeamMember>();
                otmSet.addAll(otmList);
                List<OpportunityTeamMember> uniqOtmList = new List<OpportunityTeamMember>();
                uniqOtmList.addAll(otmSet);
                insert uniqOtmList;
            }
        }
        Catch(Exception e){
            System.debug(e);
        }
*/
    }
    
}