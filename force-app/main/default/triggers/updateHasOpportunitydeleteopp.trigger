trigger updateHasOpportunitydeleteopp on Target_Initiative_Opportunity__c (after delete) {
   
    upHasOppDeleteOpp.updatefield(Trigger.old); 
    
}