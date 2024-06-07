/*
Jira Ticket Number: IBA-4438
Developer: Saptarsha Panthi
Logic: 
1. If the Opportunity has a one of the fully booked statues (Fully Booked, Commissionable - No Service PO, Non Comissionable Booking, Non Comm. Book - No Service PO, Booked with No PO, Booked with No Service PO, Booked with No Product PO) 
and has a quote in a fully booked status (Booked, Completed, Advanced Services Order, Zero Value, Offline Build Quote, VC Update in progress, VC Update price change/Errors) 
then update all quotes that have a status of Open, Auto Approved, Pending Quote Approvals, Approved, Approved by Deal Desk, or Under Rev. / Reject Approval to Cancelled. 

2. If the Opportunity has a status of Lost then update only quotes that have an open status (Open, Auto Approved, Pending Quote Approvals, Approved, Approved by Deal Desk, or Under Rev. / Reject Approval) to Cancelled.
Test Class: QuoteStatusUpdateBatch_Test
*/
Global class QuoteStatusUpdateBatch_Opps implements Database.Batchable<sObject>, Database.Stateful {//IBA-4438
    global Set<Id> listQtUpdateIds = new Set<Id>();
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String quoteIdToExclude = System.Label.QuoteIdLabel; /*IBA-4846 Change AC*/
        //String query = 'Select id, OppStatus__c From Opportunity Where RecordTypeId =:rId';
        Set<String> oppids = new Set<String>();
        List<QuoteCancelJobOppIdsforTest__c> oppidList = [Select Name, OpportunityId__c From QuoteCancelJobOppIdsforTest__c];
        for(QuoteCancelJobOppIdsforTest__c opp: oppidList){
            oppids.add(opp.OpportunityId__c);
        }
        String query;
        if(oppids.size()>0){
            query = 'Select id, OppStatus__c From Opportunity Where RecordType.DeveloperName IN (\'NAA_Opportunity\',\'US_Canada_Advanced_Services\',\'US_Canada_Specialty\') AND Id=:oppids'; //IBA-5992            
        }
        else{
            query = 'Select id, OppStatus__c From Opportunity Where RecordType.DeveloperName IN (\'NAA_Opportunity\',\'US_Canada_Advanced_Services\',\'US_Canada_Specialty\')'; //IBA-5992   
        }  
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Opportunity> oppLists){
        System.debug('r...' +oppLists.size());
        List<Id>oplostids = new List<Id>();
        List<Id>oprestids = new List<Id>();
        List<Id>opids = new List<Id>();
        String quoteIdToExclude = System.Label.QuoteIdLabel; /*IBA-4846 Change AC*/
        Map<Id,String> quoteidsmapwithoppid = new Map<Id,String>();
        List<String> quoteStatustoUpdate = new List<String>{'E0001','E0018','E0004','E0007','E0009','E0003'};
        List<String> quoteStatus = new List<String>{'E0013','E0019','E0014','E0024','E0023','E0025','E0026'};
        List<String> oppStatusbooked = new List<String>{'Non Comissionable Booking','Fully Booked','Commissionable - No Service PO','Non Comm. Book - No Service PO','Booked with No PO','Booked with No Service PO','Booked with No Product PO'};
                //List<Quote> listQtUpdate = new List<Quote>();
                for(Opportunity op:oppLists)
            {
                if(op.OppStatus__c=='Lost'){
                    oplostids.add(op.Id);
                }
                if(oppStatusbooked.contains(op.OppStatus__c)){
                  oprestids.add(op.Id);  
                }

            }
        List<Quote> quotewithopplost = [Select Id, Status, Name from Quote Where OpportunityId =:oplostids AND Status =:quoteStatustoUpdate AND Id != :quoteIdToExclude]; /*IBA-4846 Change AC*/
        for(Quote qc:quotewithopplost){
            if(qc.status!='E0017'){
                listQtUpdateIds.add(qc.id);
            }
        }
        List<Quote> quoteList = [Select id,OpportunityId,Name From Quote Where OpportunityId =:oprestids AND Status =:quoteStatus AND Id != :quoteIdToExclude]; /*IBA-4846 Change AC*/
        for(Quote q : quoteList) {        
            opids.add(q.OpportunityId);
        }
        List<quote> quotelisttoupdate = [Select Id, Name, Status from Quote Where OpportunityId=:opids AND Status =:quoteStatustoUpdate AND Id != :quoteIdToExclude]; /*IBA-4846 Change AC*/
        for(Quote qt:quotelisttoupdate){
            if(qt.status!='E0017' && !listQtUpdateIds.contains(qt.id))
            {
                listQtUpdateIds.add(qt.id);
            }
        }
        
    }
    
    global void finish(Database.BatchableContext bc){
        if(listQtUpdateIds.size() > 0){
            String quotecount = System.Label.QuoteStatusUpdateLimit;
            String Quotequery = 'Select id, Status From Quote Where Id in :listQtUpdateIds Limit ' + quotecount;
            List <Quote> quotelist = Database.query(Quotequery);
            String quoteId = System.Label.QuoteIdLabel; /*IBA-4846 Change AC*/
            System.Debug('@Developer--> Calling the QuoteStatusUpdateHTTPQueueable');
            system.enqueueJob(new QuoteStatusUpdateHTTPQueueable(quotelist, quoteId)); /*IBA-4846 Change AC*/
        }
    }
}