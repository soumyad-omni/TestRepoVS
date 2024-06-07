public class NewAccountTeamMemberCreateController {
    AccountTeamMember atm{get; set;}
    public String accid = ApexPages.currentPage().getParameters().get('accid');
    public NewAccountTeamMemberCreateController(ApexPages.StandardController controller){
        this.atm = (AccountTeamMember)controller.getRecord();
        //quote.AccountId = accid;
        atm.AccountId = accid;
        //System.debug('Atm : '+atm.OpportunityAccessLevel);
    }
    public String getaccountName(){
        String name = [select name from Account where id=:accid].Name;
        return name;
    }
    public PageReference save(){
        insert atm;
        PageReference pr = new PageReference('/'+atm.AccountId);
        pr.setRedirect(true);
        populateOpportunityTeam(atm);
        return pr;
    }
    public PageReference cancel(){
        PageReference pr = new PageReference('/'+atm.AccountId);
        pr.setRedirect(true);
        return pr;
    }
    //Added by Venu Kukkapalli - This method is written to populate New Account Team member to Opportunity Team
    Public void populateOpportunityTeam(AccountTeamMember atm){
        Boolean atmCheck;
        atmCheck = False;
        if(atm!=NULL)
            atmCheck = True;
        
        List<Opportunity> oppList = [SELECT Id,AccountId,CustomerType__c, IV_Product_Line__c,Performance_Center_Product_Line__c   FROM Opportunity WHERE stageName != '6 Closed Won' AND stageName !='7 Closed Lost' AND AccountId=:atm.AccountId];
        Account acc = [SELECT Id, OwnerId FROM Account WHERE Id=:atm.AccountId];
        //Getting Roles Based on Customer Type and Product Line
        List<Roles1__mdt> Roles=[SELECT Id, Label, QualifiedApiName, List_of_Roles__c, AllTypes__c FROM Roles1__mdt];
        String listofdefRoles;
        String listofExtRoles;
        String listofIVRoles;
        String listofPerfRoles;
        
        for(Roles1__mdt rl: Roles){
            if(rl.AllTypes__c == Label.OppTeamPopulate1){
                listofdefRoles = rl.List_of_Roles__c;
            }
            else if(rl.AllTypes__c == Label.OppTeamPopulate2){
                listofExtRoles = rl.List_of_Roles__c;
            }
            else if(rl.AllTypes__c == Label.OppTeamPopulate3){
                listofIVRoles = rl.List_of_Roles__c;
            }
            else if(rl.AllTypes__c == Label.OppTeamPopulate4){
                listofPerfRoles = rl.List_of_Roles__c;
            }
        }
        Boolean check;
        Boolean flagCheck;
        flagCheck = True;
        check = false;
        if(check == false)
            check = true;
        if(check == true)
            check = False;
        check = True;
        atmCheck = False;
        List<String> defaultList= listofdefRoles.split(',');
        List<String> extList= listofExtRoles.split(',');
        List<String> IVList= listofIVRoles.split(',');
        List<String> perfList= listofPerfRoles.split(',');
        
        List<OpportunityTeamMember> oppTeamMembersList = new List<OpportunityTeamMember>();
        
        for(Opportunity o : oppList) {
            OpportunityTeamMember opportunityTeamMember  = new OpportunityTeamMember();
            opportunityTeamMember.UserId = atm.UserId;
            opportunityTeamMember.TeamMemberRole = atm.TeamMemberRole;
            opportunityTeamMember.OpportunityId = o.ID;
            if(defaultList.contains(atm.TeamMemberRole)){
                oppTeamMembersList.add(opportunityTeamMember);
            }
            if(o.CustomerType__c == Label.OppTeamPopulate2 && extList.contains(atm.TeamMemberRole)){
                oppTeamMembersList.add(opportunityTeamMember);
            }
            if(o.IV_Product_Line__c==TRUE && IVList.contains(atm.TeamMemberRole)){
                oppTeamMembersList.add(opportunityTeamMember);
            }
            if(o.Performance_Center_Product_Line__c==TRUE && perfList.contains(atm.TeamMemberRole)){
                oppTeamMembersList.add(opportunityTeamMember);
            }
            if(atm.UserId == acc.ownerId && !oppTeamMembersList.contains(opportunityTeamMember)){
                oppTeamMembersList.add(opportunityTeamMember);
            }
        }
        flagCheck = True;
        if(flagCheck==True)
            flagCheck= False;
        if(flagCheck== False)
            flagCheck = True;
        flagCheck = False;
        check = true;
        atmCheck = True;
        if(oppTeamMembersList.size()>0){
            Set<OpportunityTeamMember> otmSet = new Set<OpportunityTeamMember>();
            otmSet.addAll(oppTeamMembersList);
            List<OpportunityTeamMember> uniqOtmList = new List<OpportunityTeamMember>();
            uniqOtmList.addAll(otmSet);
            insert uniqOtmList;
        }
    }
}