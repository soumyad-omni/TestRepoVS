trigger PreventDelete on OpportunityTeamMember (before delete, before update,after insert) {
    String usrProfileName = [select u.Profile.Name from User u where u.id = :Userinfo.getUserId()].Profile.Name;    
    Boolean isError = false;
    if(Trigger.isInsert)
    {
        list<OpportunityTeamMember> oppTeamList = Trigger.NEW;
        list<Opportunity_Team_Members_History__c> otmhAudits = new list<Opportunity_Team_Members_History__c>();
        for(OpportunityTeamMember var : oppTeamList)
        {
            Opportunity_Team_Members_History__c OTMH = new Opportunity_Team_Members_History__c(Opportunity__c = var.OpportunityId,
                                                                                               User__c = var.UserId,
                                                                                               Team_Role__c = var.TeamMemberRole,
                                                                                               ParentId__c = var.Id,
                                                                                               OpportunityAccessLevel__c = var.OpportunityAccessLevel,
                                                                                               Compensation__c = var.Compensation__c,
                                                                                               Deleted_Record__c = false,
                                                                                               New_Record__c = true);
            otmhAudits.add(OTMH);
        }   
        insert otmhAudits; 
    }
    if(Trigger.isDelete && (CreateOpportunityTeamMembers.skipOpportunityTeamMemberTrigger != true)) {
        if((usrProfileName != 'Business Administrator')&&(usrProfileName != 'System Administrator'))
        {
            for (OpportunityTeamMember e : Trigger.old) {
                e.addError('Only Business Administrator/System Administrator can delete Opportunity Team!');
                isError = true;
            }        
        }
        
        if(!isError) {
            list<OpportunityTeamMember> oppTeamList = Trigger.OLD;
            list<Opportunity_Team_Members_History__c> otmhAudits = new list<Opportunity_Team_Members_History__c>();
            for(OpportunityTeamMember var : oppTeamList)
            {
                Opportunity_Team_Members_History__c OTMH = new Opportunity_Team_Members_History__c(Opportunity__c = var.OpportunityId,
                                                                                                   User__c = var.UserId,
                                                                                                   Team_Role__c = var.TeamMemberRole,
                                                                                                   ParentId__c = var.Id,
                                                                                                   OpportunityAccessLevel__c = var.OpportunityAccessLevel,
                                                                                                   Compensation__c = var.Compensation__c,
                                                                                                   Deleted_Record__c = true);
                otmhAudits.add(OTMH);
            }   
            insert otmhAudits;
        }
        
    }
    if(Trigger.isUpdate && (CreateOpportunityTeamMembers.skipOpportunityTeamMemberTrigger != true)){
        if((usrProfileName != 'Business Administrator')&&(usrProfileName != 'System Administrator')) {
            System.debug('just before update..........');
            for (OpportunityTeamMember e : Trigger.new) {
                e.addError('Only Business Administrator/System Administrator can update Opportunity Team!');
                isError = true;
            }            
        }
        if(!isError)
        {
            Map<Id,OpportunityTeamMember> oppTeamMap = Trigger.OLDMAP;
            list<OpportunityTeamMember> updatedOppTeamList = Trigger.NEW;
            list<Opportunity_Team_Members_History__c> otmhAudits = new list<Opportunity_Team_Members_History__c>();
            for(OpportunityTeamMember var : updatedOppTeamList)
            {
                Opportunity_Team_Members_History__c OTMH = new Opportunity_Team_Members_History__c();
                OTMH.ParentId__c = var.Id;
                OTMH.Opportunity__c = var.OpportunityId;
                OpportunityTeamMember oldOppTeamMember = (OpportunityTeamMember)oppTeamMap.get(var.Id);
                if(var.UserId != oldOppTeamMember.UserId)
                { OTMH.User__c = var.UserId; OTMH.OldUser__c = oldOppTeamMember.UserId;}
                if(var.TeamMemberRole != oldOppTeamMember.TeamMemberRole)
                {OTMH.Team_Role__c = var.TeamMemberRole;OTMH.OldTeamRole__c = oldOppTeamMember.TeamMemberRole;}
                if(var.OpportunityAccessLevel != oldOppTeamMember.OpportunityAccessLevel)
                {OTMH.OpportunityAccessLevel__c = var.OpportunityAccessLevel;OTMH.OldOpportunityAccessLevel__c = oldOppTeamMember.OpportunityAccessLevel;}
                if(var.Compensation__c != oldOppTeamMember.Compensation__c)
                {OTMH.Compensation__c = var.Compensation__c;OTMH.OldCompensation__c = oldOppTeamMember.Compensation__c;}                                                                                             
                otmhAudits.add(OTMH);
            } 
            insert otmhAudits;
            
        }
    }
    
}