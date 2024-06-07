public class UpdateTotalContractValue implements Queueable {
    
    private list<Opportunity> opportunityDetails;
    
    public UpdateTotalContractValue(list<Opportunity> opp) {
        this.opportunityDetails = opp;
    }
    
    public void execute(QueueableContext context) {
        Set<Id> oppId = new Set<id>();
        Decimal ExpectedBookings = 0.00;
        List<Opportunity> updateOpp = new List<Opportunity>();
        List<Opportunity> parentOpp = new List<Opportunity>();
        System.debug('##### opportunityDetails ' + opportunityDetails);
        if(opportunityDetails.size()>0){
            for(Opportunity o : opportunityDetails){
                if(o.Associated_Opportunity__c != null){
                    oppId.add(o.Associated_Opportunity__c);
                }else{
                    oppId.add(o.id); 
                    //  ExpectedBookings = o.Expected_Bookings__c;
                }
                
            }
        }
        System.debug('***InitialExpectedBookings'+ ExpectedBookings);
        System.debug('***oppId'+ oppId);
        List<Opportunity> childOpp = [Select Id, Expected_Bookings__c,Associated_Opportunity__c, Total_Contract_Value__c from Opportunity where Associated_Opportunity__c IN : oppId and Opportunity__c = 'Specialty'];
        System.debug('***childOpp.size()'+ childOpp.size());
        if(childOpp.size() >0){
            for(Opportunity o : childOpp){
                if(o.Expected_Bookings__c == NULL){
                    o.Expected_Bookings__c = 0.00;
                }
                ExpectedBookings = ExpectedBookings + o.Expected_Bookings__c;
                System.debug('***ChildExpectedBookings'+ ExpectedBookings);
            }
        }
        updateOpp.addAll(childOpp);
        parentOpp = [Select Id, Expected_Bookings__c,Associated_Opportunity__c, Total_Contract_Value__c from Opportunity where Id IN : oppId and Opportunity__c = 'Specialty'];
        System.debug('***parentOpp.size()'+ parentOpp.size());
        if(parentOpp.size() >0){
            for(Opportunity o : parentOpp){
                if(o.Expected_Bookings__c == NULL){
                    o.Expected_Bookings__c = 0.00;
                }
                ExpectedBookings = ExpectedBookings + o.Expected_Bookings__c;
                System.debug('***ParentExpectedBookings'+ ExpectedBookings);
            }
            updateOpp.addAll(parentOpp);
        }         
        System.debug('***TotalExpectedBookings'+ ExpectedBookings); 
        for(Opportunity o : updateOpp){
            o.Total_Contract_Value__c = ExpectedBookings;
        }
        AccountTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDIsabled = true;
        update updateOpp;
        system.debug('***updateOpp '+updateOpp);
    }
}