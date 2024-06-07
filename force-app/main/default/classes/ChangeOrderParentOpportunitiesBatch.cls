/* 
 * Batch Class to Insert Change Order Opportunity records for Top level Oportunities i.e., ASSICIATED OPPORTUNITIES == NULL
 * Ids are sent from Batch Class: ChangeOrderChildOpportunitiesBatch
 */
global class ChangeOrderParentOpportunitiesBatch implements Database.Batchable<sObject>, Database.Stateful {
    //to capture the IDs sent from previous class
    public Set<Id> oppIds 					= new Set<Id>();
    
    //top capture the top level Ids in a map and send to next batch class
    public Map<Id, Id> topLevelOppIdMap 	= new Map<Id, Id>();
    public Map<Id, Date> topLevelOppCloseDateMap 	= new Map<Id, Date>();
    
    public ChangeOrderParentOpportunitiesBatch(Set<Id> oppIdSet) {
        oppIds = oppIdSet;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        Datetime lastRunDt = ChangeOrderChildOpportunitiesBatch.getBatchLastRunTime('ChangeOrderParentOpportunitiesBatch');
        
        system.debug('oppIds-->'+oppIds);
        String query 	= ' SELECT id, name, Opportunity_Number__c, Associated_Opportunity__c, Associated_Opportunity__r.name, Associated_Opportunity__r.Opportunity_Number__c, ownerId,';
        query 			= query + ' PrimaryQuote__c, Opportunity__c, PrimaryQuote__r.Conga_Total_Product__c, PrimaryQuote__r.Conga_Total_Support_Services__c, PrimaryQuote__r.Conga_Total_Shipping_and_Handling__c,';
        query 			= query + ' PrimaryQuote__r.Conga_Grand_Total__c,PrimaryQuote__r.Account_CSN__c, PrimaryQuote__r.SAP_Quote_Number_Truncated__c ,Associated_Opportunity__r.Associated_Opportunity__c,';
        query 			= query + ' Expected_Bookings_Real__c, CloseDate, PrimaryQuote__r.Booking_Date__c, Account.Top_level_1__c, PrimaryQuote__r.Order_Type__c';
        query 			= query + ' FROM Opportunity';
        query 			= query + ' WHERE (Id IN :oppIds OR Associated_Opportunity__c = NULL) AND Opportunity__c in (\'Omnicell Opportunity\')';
        query 			= query + ' AND StageName = \'6 Closed Won\'';
        query 			= query + ' AND OppStatus__c in (\'Booked with No PO\',\'Booked with No Product PO\',\'Booked with No Service PO\',\'Non Comm. Book - No Service PO\',\'Commissionable - No Service PO\',\'Fully Booked\',\'Non Comissionable Booking\')';
        query			= query + ' AND RecordType.DeveloperName IN (\'NAA_Opportunity\',\'US_Canada_Advanced_Services\',\'US_Canada_Specialty\')';//IBA-5024
        query			= query + ' AND (NOT account.name like \'%omnicell%\')';
        //query			= query + ' AND CloseDate < 2022-01-01 AND CloseDate >= 2021-04-01';
        
        if(lastRunDt <> NULL)
        {
            lastRunDt = lastRunDt.addDays(-1);
            query		= query + ' AND (Lastmodifieddate >: lastRunDt OR PrimaryQuote__r.Lastmodifieddate >: lastRunDt)';
        }
        
        system.debug('query-->'+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity> oppList) 
    {
        List<Change_Order_Opportunity__c> cooUpsertList 		= new List<Change_Order_Opportunity__c>();
        Map<Id, Change_Order_Opportunity__c> cooExistingMap 	= new Map<Id, Change_Order_Opportunity__c>();
        
        for(Change_Order_Opportunity__c coo : [SELECT id, Opportunity__c FROM Change_Order_Opportunity__c 
                                               WHERE Opportunity__c IN :oppList])
        {
            cooExistingMap.put(coo.Opportunity__c, coo);
        }
        
        for(Opportunity opp : oppList)
        {
            Change_Order_Opportunity__c coo 	= ChangeOrderChildOpportunitiesBatch.generateChangeOrderOpportunity(opp);
            coo.Top_Level_Opportunity__c 		= opp.id;//As this opportunity is top level
            
            if(cooExistingMap.containsKey(opp.Id))
            {
                coo.Id = cooExistingMap.get(opp.Id).id;
            }
            
            cooUpsertList.add(coo);
            
            topLevelOppIdMap.put(opp.Id,opp.Id);
            topLevelOppCloseDateMap.put(opp.Id, opp.CloseDate);
        }
        
        if(!cooUpsertList.isEmpty())
        {
            upsert cooUpsertList;
        }
    }
    
    global void finish(Database.BatchableContext BC)
    {
        system.debug('inside final parent batch--'+topLevelOppIdMap);
        system.debug('topLevelOppCloseDateMap-->'+topLevelOppCloseDateMap);
        
        ChangeOrderChildOpportunitiesBatch.upsertBatchLastRunTime('ChangeOrderParentOpportunitiesBatch');
        
        //Sending Ids Map of Top Level Opportunities to next class 
        //if(!topLevelOppIdMap.isEmpty())
        //{
            //database.executeBatch(new ChangeOrderTopLevelOpportunitiesBatch(topLevelOppIdMap, topLevelOppCloseDateMap), 50);
            database.executeBatch(new ChangeOrderTopLevelOpportunitiesBatch(null, null), 50);
        //}
    }
}