Global class importDataFromCSV_EmailResult implements Database.Batchable<sObject>, Database.Stateful, Schedulable{
    global List<Id> opportunityIds = new List<Id>();
    global String role = '';
    global String user = '';
    global Date startDate;
    global Date endDate;
    global String stat = '';
    global String err = '';
    public String csv = 'OpportunityTeamMember Id'+ ',' +'User'+ ',' +'Old Role'+ ',' +'New Role'+ ',' +'Opportunity Id'+ ',' +'Error Details\n';
    global list<OpportunityTeamMember> oldOppTeamList1 = new list<OpportunityTeamMember>();
    global map<string,string> errMap = new map<string,string>();

    global Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('opp id '+opportunityIds);
        return Database.getQueryLocator([SELECT Id, AccountId, Territory2Id, OwnerId, Account.Facility_Type__c from Opportunity
        WHERE Id IN :opportunityIds]);
    }

    global void execute(Database.BatchableContext BC, List<Opportunity> oppList)
    {
        List<String> oppIds = new List<String>();
        for(Opportunity opp : oppList)
        {
            oppIds.add(opp.id);
        }
        map<id,list<OpportunityTeamMember>> oldOppTeamList = new map<id,list<OpportunityTeamMember>>();
        system.debug('oldOppTeamList '+oldOppTeamList1.size());
        for(OpportunityTeamMember opm:oldOppTeamList1){

            if(oldOppTeamList.containskey(opm.OpportunityId)){
                list<OpportunityTeamMember> oldOppTeamList11 = oldOppTeamList.get(opm.OpportunityId);
                oldOppTeamList11.add(opm);
                oldOppTeamList.put(opm.OpportunityId,oldOppTeamList11);
            }else{
                list<OpportunityTeamMember> oldOppTeamList11 = new list<OpportunityTeamMember>();
                oldOppTeamList11.add(opm);
                oldOppTeamList.put(opm.OpportunityId,oldOppTeamList11);
            }

        }

        List<OpportunityTeamMember> oppTeamList = new List<OpportunityTeamMember>();

        if((user == '' && role == null)||(user == '' && role == '')){
            oppTeamList =[Select Id, OpportunityId, UserId, TeamMemberRole,OpportunityAccessLevel,Compensation__c,User.name from OpportunityTeamMember where OpportunityId in: oppIds];
        }
        else if((user != '' && role == null)||(user != '' && role == '')){
            oppTeamList =[Select Id, OpportunityId, UserId, TeamMemberRole,OpportunityAccessLevel,Compensation__c,User.name from OpportunityTeamMember where OpportunityId in: oppIds and User.name =: user];
        }
        else if(user == '' && role != null && role != ''){
            oppTeamList =[Select Id, OpportunityId, UserId, TeamMemberRole,OpportunityAccessLevel,Compensation__c,User.name from OpportunityTeamMember where OpportunityId in: oppIds and TeamMemberRole =: role];
        }
        else{
            oppTeamList =[Select Id, OpportunityId, UserId, TeamMemberRole,OpportunityAccessLevel,Compensation__c,User.name from OpportunityTeamMember where OpportunityId in: oppIds and (User.name =: user or TeamMemberRole =: role)];
        }

        List<OpportunityTeamMember> oldOppTeamList2 = new List<OpportunityTeamMember>();
        for(id opId:oppIds){
            if(oldOppTeamList.containskey(opId)){
                oldOppTeamList2.addall(oldOppTeamList.get(opId));
            }
        }

        map<id,OpportunityTeamMember> oldOppTeamMap = new map<id,OpportunityTeamMember>();
        if(oldOppTeamList2.size() > 0){
            for(OpportunityTeamMember otmO:oldOppTeamList2){
                oldOppTeamMap.put(otmO.UserId, otmO);
            }
        }

        map<id,OpportunityTeamMember> newOppTeamMap = new map<id,OpportunityTeamMember>();
        if(oppTeamList.size() > 0){
            for(OpportunityTeamMember otmN:oppTeamList){
                if(oldOppTeamMap.containskey(otmN.UserId)){
                    OpportunityTeamMember oldTeam = oldOppTeamMap.get(otmN.UserId);
                    if(otmN.TeamMemberRole != oldTeam.TeamMemberRole){
                        string row = otmN.id + ',' + otmN.User.name + ',' + oldTeam.TeamMemberRole + ', ' + otmN.TeamMemberRole + ', ' + otmN.OpportunityId + ', ' + '';
                        csv += row + '\n';
                    }
                }
            }
        }

    }

    global void finish(Database.BatchableContext BC)
    {
        AsyncApexJob a = [Select Id, Status,ExtendedStatus,NumberOfErrors,JobItemsProcessed,TotalJobItems, CreatedBy.Email from AsyncApexJob where Id =:BC.getJobId()];

        for(string err:errMap.keyset()){
            string row = '' + ',' + '' + ',' + '' + ', ' + '' + ', ' + err + ', ' + errMap.get(err);
            csv += row + '\n';
        }
        
        try{
            Messaging.EmailFileAttachment csvAttachment = new Messaging.EmailFileAttachment();
            Blob csvBlob = blob.valueOf(csv);
            String csvName = 'UpdateInfo.csv';
            csvAttachment.setFileName(csvName);
            csvAttachment.setBody(csvBlob);
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {a.CreatedBy.Email};
            email.setSubject('Opportunity Team Update Batch' + stat);
            email.setToAddresses(toAddresses);
            /*OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'donotreply@omnicell.com'];
            if ( owea.size() > 0 ) {
                email.setOrgWideEmailAddressId(owea.get(0).Id);
            }*/
            string emailBody = 'Batch has completed with '+err+' failures.';
            emailBody = emailBody + '<br/>Start Date: '+startDate;
            emailBody = emailBody + '<br/>End Date : '+endDate;
            emailBody = emailBody + '<br/>User : '+user;
            emailBody = emailBody + '<br/>Role in Territory : '+role;
            emailBody = emailBody + '<br/>Details of the changes are in the attached file.';
            email.setHtmlBody(emailBody);
            email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttachment});
            Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});

        }
        catch(Exception EX)
        {
            System.debug('The email failed to send: ' + Ex.getMessage());
        }

    }

    global void execute(SchedulableContext SC) {
        importDataFromCSV_EmailResult createOppTMBatch = new importDataFromCSV_EmailResult();
        createOppTMBatch.opportunityIds = opportunityIds;
        createOppTMBatch.user = user;
        createOppTMBatch.role = role;
        createOppTMBatch.startDate = startDate;
        createOppTMBatch.endDate = endDate;
        createOppTMBatch.stat = stat;
        createOppTMBatch.err = err;
        createOppTMBatch.oldOppTeamList1 = oldOppTeamList1;
        Database.executeBatch(createOppTMBatch, 1);
        System.AbortJob(SC.getTriggerId());
    }
}