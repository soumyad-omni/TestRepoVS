/* 
 * Batch Class to Insert Change Order Opportunity records from Oportunities where ASSICIATED OPPORTUNITIES != NULL (i.e., child opportunities)
 */ 
global class ChangeOrderChildOpportunitiesBatch implements Database.Batchable<sObject>, schedulable, Database.Stateful 
{
    //To capture the parent opportunity Id to be used in query in next batch class
    public Set<Id> associatedOpportunityIds = new Set<id>();
    
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        Datetime lastRunDt = getBatchLastRunTime('ChangeOrderChildOpportunitiesBatch');
        
        String query 	= 'SELECT id, name, Opportunity_Number__c, Associated_Opportunity__c, Associated_Opportunity__r.name, Associated_Opportunity__r.Opportunity_Number__c, ownerId,Associated_Opportunity__r.Opportunity__c, ';
        query 			= query + ' PrimaryQuote__c, Opportunity__c, PrimaryQuote__r.Conga_Total_Product__c, PrimaryQuote__r.Conga_Total_Support_Services__c, PrimaryQuote__r.Conga_Total_Shipping_and_Handling__c,';
        query 			= query + ' PrimaryQuote__r.Conga_Grand_Total__c,PrimaryQuote__r.Account_CSN__c, PrimaryQuote__r.SAP_Quote_Number_Truncated__c , Associated_Opportunity__r.Associated_Opportunity__c,';
        query 			= query + ' Expected_Bookings_Real__c, CloseDate, PrimaryQuote__r.Booking_Date__c, Account.Top_level_1__c, PrimaryQuote__r.Order_Type__c';
        query 			= query + ' FROM Opportunity';
        query 			= query + ' WHERE Opportunity__c in (\'Change Order - Credit\' , \'Change Order - Debit\',\'Omnicell Opportunity\') and Associated_Opportunity__c <> NULL';
        query 			= query + ' AND StageName = \'6 Closed Won\'';
        query 			= query + ' AND OppStatus__c in (\'Booked with No PO\',\'Booked with No Product PO\',\'Booked with No Service PO\',\'Non Comm. Book - No Service PO\',\'Commissionable - No Service PO\',\'Fully Booked\',\'Non Comissionable Booking\')';
        query			= query + ' AND RecordType.DeveloperName IN (\'NAA_Opportunity\',\'US_Canada_Advanced_Services\',\'US_Canada_Specialty\')';//IBA-5024
        query			= query + ' AND (NOT account.name like \'%omnicell%\')';
        //query			= query + ' AND CloseDate < 2022-01-01 AND CloseDate >= 2021-04-01';
        //query			= query + ' AND Associated_Opportunity__c = \'0063l00000iWk2QAAS\'';
        
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
            if(opp.Associated_Opportunity__c != null && opp.Associated_Opportunity__r.Opportunity__c =='MTS Opportunity'){
                
            }else{
                Change_Order_Opportunity__c coo 				= generateChangeOrderOpportunity(opp);
                
                if(cooExistingMap.containsKey(opp.Id))
                {
                    coo.Id = cooExistingMap.get(opp.Id).id;
                }
                
                cooUpsertList.add(coo);
                
                //if the parent opportunity is top level then add parentId to the list
                if(opp.Associated_Opportunity__r.Associated_Opportunity__c == NULL)
                {
                    associatedOpportunityIds.add(opp.Associated_Opportunity__c);
                }
            }
            
        }
        
        if(!cooUpsertList.isEmpty())
        {
            upsert cooUpsertList;
        }
    }
    
    global void finish(Database.BatchableContext BC)
    {
        system.debug('inside final child batch');
        system.debug('associatedOpportunityIds-->'+associatedOpportunityIds);
        upsertBatchLastRunTime('ChangeOrderChildOpportunitiesBatch');
        //Sending the list of top  level opportunities Ids to next batch 
        //if(!associatedOpportunityIds.isEmpty())
            database.executeBatch(new ChangeOrderParentOpportunitiesBatch(associatedOpportunityIds), 50);
    }
    
    global void execute(SchedulableContext SC) {
        database.executebatch(new ChangeOrderChildOpportunitiesBatch(),10);
    }
    
    //generating a instance of Change_Order_Opportunity__c for inserting - used in other batch class too
    public static Change_Order_Opportunity__c generateChangeOrderOpportunity(Opportunity opp)
    {
        Integer i = 1;
        Change_Order_Opportunity__c coo 				= new Change_Order_Opportunity__c();
        coo.Associated_Opportunity__c 					= opp.Associated_Opportunity__c;
        coo.Associated_Opportunity_Name__c 				= opp.Associated_Opportunity__r.name;
        coo.Associated_Opportunity_Number__c 			= opp.Associated_Opportunity__r.Opportunity_Number__c;
        coo.Opportunity__c 								= opp.Id;
        coo.Opportunity_Expected_Bookings__c 			= opp.Expected_Bookings_Real__c;
        coo.Opportunity_Expected_Close_Date__c 			= opp.CloseDate;
        coo.Opportunity_Name__c 						= opp.name;
        coo.Opportunity_Number__c 						= opp.Opportunity_Number__c;
        coo.Opportunity_Type__c 						= opp.Opportunity__c;
        coo.Primary_Quote__c 							= opp.PrimaryQuote__c;
        coo.Primary_Quote_Booking_Date__c 				= opp.PrimaryQuote__r.Booking_Date__c;
        coo.Primary_Quote_CSN__c 						= opp.PrimaryQuote__r.Account_CSN__c;
        coo.Primary_Quote_Number__c 					= opp.PrimaryQuote__r.SAP_Quote_Number_Truncated__c;
        
        if(coo.Opportunity_Type__c <> NULL && coo.Opportunity_Type__c == 'Change Order - Credit')
        {
            i = -1; //If change order credit then show values in negative
        }
        
        coo.Primary_Quote_Grand_Total__c 				= (opp.PrimaryQuote__r.Conga_Grand_Total__c == NULL ? 0 : opp.PrimaryQuote__r.Conga_Grand_Total__c) * i;
        coo.Primary_Quote_Total_Product__c 				= (opp.PrimaryQuote__r.Conga_Total_Product__c == NULL ? 0 : opp.PrimaryQuote__r.Conga_Total_Product__c) * i;
        coo.Primary_Quote_Total_Support_Services__c 	= (opp.PrimaryQuote__r.Conga_Total_Support_Services__c == NULL ? 0 : opp.PrimaryQuote__r.Conga_Total_Support_Services__c) * i;
        coo.Opportunity_Owner__c 						= opp.ownerId;
        coo.Opportunity_Closed_Date_Quater__c 			= returnQuater(coo.Opportunity_Expected_Close_Date__c);
        coo.Primary_Quote_Order_Type__c 				= opp.PrimaryQuote__r.Order_type__c;
        //coo.Parent_Account__c 						= ID.valueOf(opp.Account.Top_level_1__c);
        
        if(opp.PrimaryQuote__r.Conga_Total_Shipping_and_Handling__c <> NULL && opp.PrimaryQuote__r.Conga_Total_Shipping_and_Handling__c <> '')
            coo.Primary_Quote_Total_Shipping_Handling__c = (Decimal.valueOf(opp.PrimaryQuote__r.Conga_Total_Shipping_and_Handling__c) == NULL ? 0 : Decimal.valueOf(opp.PrimaryQuote__r.Conga_Total_Shipping_and_Handling__c)) * i;
        
        return coo;
    }
    
    public static string returnQuater(Date dt)
    {
        if(dt == NULL)
            return '';
        Integer month = dt.month();
        if(month <= 3)
            return dt.year() + ' Q1';
        else if(month <= 6)
            return dt.year() + ' Q2';
        else if(month <= 9)
            return dt.year() + ' Q3';
        else
            return dt.year() + ' Q4';
    }
    
    public static void upsertBatchLastRunTime(String className)
    {
        List<Batch_Job_Last_Run_DateTime__c> upsertBatchRunTime = new List<Batch_Job_Last_Run_DateTime__c>();
        
        upsertBatchRunTime = [SELECT id FROM Batch_Job_Last_Run_DateTime__c WHERE Class_Name__c = :className 
                              ORDER BY Last_Run_Datetime__c DESC
                              LIMIT 1];
        
        if(!upsertBatchRunTime.isEmpty())
        {
            upsertBatchRunTime[0].Last_Run_Datetime__c = datetime.now();
        }
        else
        {
            Batch_Job_Last_Run_DateTime__c obj = new Batch_Job_Last_Run_DateTime__c();
            obj.Class_Name__c = className;
            obj.Last_Run_Datetime__c = datetime.now();
            upsertBatchRunTime.add(obj);
        }
        
        upsert upsertBatchRunTime;
    }
    
    public static DateTime getBatchLastRunTime(String className)
    {
        List<Batch_Job_Last_Run_DateTime__c> upsertBatchRunTime = new List<Batch_Job_Last_Run_DateTime__c>();
        
        upsertBatchRunTime = [SELECT id, Last_Run_Datetime__c FROM Batch_Job_Last_Run_DateTime__c WHERE Class_Name__c = :className 
                              ORDER BY Last_Run_Datetime__c DESC
                              LIMIT 1];
        
        if(!upsertBatchRunTime.isEmpty())
        {
            return upsertBatchRunTime[0].Last_Run_Datetime__c;
        }
        
        return null;
    }
}