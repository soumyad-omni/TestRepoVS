Global class importDataFromCSV_Batch implements Database.Batchable<sObject>, Database.Stateful{//IBA-6127
    global List<Id> opportunityIds = new List<Id>();
    global String role_selected = '';
    global String user_selected = '';
    global Date startDate;//IBA-6127
    global Date endDate;//IBA-6127
    public List<String> oppIds = new List<String>();//IBA-6127
    global list<OpportunityTeamMember> oldOppTeamList1 = new list<OpportunityTeamMember>();//IBA-6127
    global map<string,string> errMap = new map<string,string>();//IBA-6127

    global Database.QueryLocator start(Database.BatchableContext BC){
        //IBA-6127 start
        List<OpportunityTeamMember> oppTeamList = new List<OpportunityTeamMember>();//IBA-6127
        if((user_selected == '' && role_selected == null)||(user_selected == '' && role_selected == '')){
            oppTeamList =[Select Id, OpportunityId, UserId, TeamMemberRole,OpportunityAccessLevel,Compensation__c from OpportunityTeamMember where OpportunityId in: opportunityIds];
        }
        else if((user_selected != '' && role_selected == null)||(user_selected != '' && role_selected == '')){
            oppTeamList =[Select Id, OpportunityId, UserId, TeamMemberRole,OpportunityAccessLevel,Compensation__c from OpportunityTeamMember where OpportunityId in: opportunityIds and User.name =: user_selected];
        }
        else if(user_selected == '' && role_selected != null && role_selected != ''){
            oppTeamList =[Select Id, OpportunityId, UserId, TeamMemberRole,OpportunityAccessLevel,Compensation__c from OpportunityTeamMember where OpportunityId in: opportunityIds and TeamMemberRole =: role_selected];
        }
        else{
            oppTeamList =[Select Id, OpportunityId, UserId, TeamMemberRole,OpportunityAccessLevel,Compensation__c from OpportunityTeamMember where OpportunityId in: opportunityIds and (User.name =: user_selected or TeamMemberRole =: role_selected)];
        }

        for(OpportunityTeamMember opp:oppTeamList){
            OpportunityTeamMember opt = new OpportunityTeamMember(OpportunityId = opp.OpportunityId, UserId = opp.UserId, TeamMemberRole=opp.TeamMemberRole);
            oldOppTeamList1.add(opt);
        }


        //IBA-6127 end
        return Database.getQueryLocator([SELECT Id, AccountId, Territory2Id, OwnerId, Account.Facility_Type__c from Opportunity
        WHERE Id IN :opportunityIds]);
    }

    global void execute(Database.BatchableContext BC, List<Opportunity> oppList)
    {
        for(Opportunity opp : oppList)
        {
            opp.Update_Opportunity_Team_DateTime__c = datetime.now();
            opp.Update_Opportunity_Team_Selected_Role__c = role_selected;
            opp.Update_Opportunity_Team_User__c = user_selected;
            opp.Update_Opportunity_Team_Status__c = 'Open';
            oppIds.add(opp.id);
        }

        try{
            update oppList;

            CreateOpportunityTeamMembers job = new CreateOpportunityTeamMembers();
            job.oppFullList = oppList;
            job.user = user_selected;
            job.role = role_selected;
            system.debug('####role_selected: '+ role_selected);
            system.debug('####role_selected: '+ user_selected);
            System.enqueueJob(job);
        }catch(Exception EX){
            System.debug('The email failed to send: ' + Ex.getMessage());
            errMap.put(oppList[0].id, Ex.getMessage());
        }
        
    }

    global void finish(Database.BatchableContext BC)
    {
        AsyncApexJob a = [Select Id, Status,ExtendedStatus,NumberOfErrors,JobItemsProcessed,TotalJobItems, CreatedBy.Email from AsyncApexJob where Id =:BC.getJobId()];

        system.debug('oldOppTeamList '+oldOppTeamList1.size());
        //IBA-6127 start
        DateTime newDateTime = Datetime.now().addMinutes(integer.valueof(System.Label.OppTeamMemResDelay));
        String hour = String.valueOf(newDateTime.hour());
        String min = String.valueOf(newDateTime.minute());
        String ss = String.valueOf(newDateTime.second());
        String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';

        importDataFromCSV_EmailResult createOppTMBatch = new importDataFromCSV_EmailResult();
        createOppTMBatch.opportunityIds = opportunityIds;
        createOppTMBatch.user = user_selected;
        createOppTMBatch.role = role_selected;
        createOppTMBatch.startDate = startDate;
        createOppTMBatch.endDate = endDate;
        createOppTMBatch.stat = a.Status;
        createOppTMBatch.err = string.valueOf(a.NumberOfErrors);
        createOppTMBatch.oldOppTeamList1 = oldOppTeamList1;
        createOppTMBatch.errMap = errMap;
        System.schedule('Opp Team Update batch result'+string.valueof((Math.random() * 1000)), nextFireTime ,createOppTMBatch);
        //IBA-6127 end

    }
}