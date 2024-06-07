/* 
* Batch Class to insert quote line details
* Test Class: ChangeOrderChildOpportunitiesBatchTest
*/ 
global class ChangeOrderQuoteLineBatch implements Database.Batchable<sObject>, Database.Stateful {
    public string batchType;
    public ChangeOrderQuoteLineBatch(String runType)
    {
        batchType = runType;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        Datetime lastRunDt = ChangeOrderChildOpportunitiesBatch.getBatchLastRunTime('ChangeOrderQuoteLineBatch');
        
        //getting list of all Change_Order_Opportunity__c where primary quote is not null
        String query 	= 'SELECT id, quote__c, CurrencyIsoCode, Higher_Level_Item__c, Labor_Cost__c, Line_Expected_Booking__c, ';
        query 			= query + ' Line_Item_Description__c, List_Price__c, Material_Type__c, Overhead_Cost__c, Par_Location__c,';
        query 			= query + ' Part_of_a_Bundle__c, Pricing_Reference_Model__c, Product_Code__c, Product_Cost__c, Quantity__c,';
        query 			= query + ' Requested_Delivery_Date__c, SAP_Line_Item_GUID__c, SAP_Line_Number__c, SAP_NPV__c, Total_Cost2__c,';
        query			= query + ' Product__r.Portfolio_Segment__c, SAP_Quote_Number__c,Quote__r.Status, Product__r.SAP_Product_Type__c,';
        query			= query + ' Quote__r.Order_Type__c, Quote__r.Opportunity.OpportunityGroup__c,';
        query           = query + ' Quote__r.Opportunity.Opportunity__c'; //IBA-5787 Saptarsha Panthi
        query 			= query + ' FROM Quote_line__c';
        query 			= query + ' WHERE';
        //query 			= query + 'Quote__c='' AND'
        if(lastRunDt <> NULL)
        {
            lastRunDt = lastRunDt.addDays(-1);
            if(batchType == NULL)
            {
                query 		= query + ' quote__c IN (select primary_quote__c from Change_Order_Opportunity__c where Lastmodifieddate >: lastRunDt)';
                batchType = 'checkQuoteLineDate';
            }
            else if(batchType == 'checkQuoteLineDate')
            {
                query 		= query + ' quote__c IN (select primary_quote__c from Change_Order_Opportunity__c)';
                query		= query + ' AND Lastmodifieddate >: lastRunDt';
                batchType = 'stopBatch';
            }
        }
        else
        {
            query 		= query + ' quote__c IN (select primary_quote__c from Change_Order_Opportunity__c)';
        }
        
        system.debug('query-->'+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Quote_line__c> qlList) 
    {
        List<Change_Order_Quote_Line__c> changeOrderQLUpsertList = new List<Change_Order_Quote_Line__c>();
        Map<Id, Change_Order_Quote_Line__c> changeOrderQLExistingMap = new Map<Id, Change_Order_Quote_Line__c>();
        Map<id, Change_Order_Opportunity__c> changeOrderOppQuoteMap = new Map<id, Change_Order_Opportunity__c>();
        List<id> quoteIds = new List<id>();
        List<Change_Order_Tableau__c> cotUpsertList = new List<Change_Order_Tableau__c>();
        
        for(Change_Order_Quote_Line__c coql : [SELECT id,Quote_Line__c FROM Change_Order_Quote_Line__c
                                               WHERE Quote_Line__c IN :qlList])
        {
            changeOrderQLExistingMap.put(coql.Quote_Line__c, coql);
        }
        
        for(Quote_line__c ql : qlList)
        {
            quoteIds.add(ql.Quote__c);
        }
        
        for(Change_Order_Opportunity__c coo : [SELECT id, primary_quote__c, Opportunity_Closed_Date_Quater__c, Opportunity_Expected_Close_Date__c,
                                               Opportunity_Number__c, Opportunity_Type__c, Primary_Quote_Number__c
                                               FROM Change_Order_Opportunity__c
                                               WHERE primary_quote__c IN :quoteIds])
        {
            changeOrderOppQuoteMap.put(coo.Primary_Quote__c, coo);
        }
        
        for(Quote_line__c ql : qlList)
        {
            Change_Order_Quote_Line__c coql 		= new Change_Order_Quote_Line__c();
            if(changeOrderQLExistingMap.containsKey(ql.id))
            {
                coql.Id 							= changeOrderQLExistingMap.get(ql.id).id;
            }
            coql.Quote_Line__c 						= ql.Id;
            if(changeOrderOppQuoteMap.containsKey(ql.Quote__c))
            {
                coql.Change_Order_Opportunity__c 	= changeOrderOppQuoteMap.get(ql.Quote__c).Id;
            }
            coql.Currency__c 						= ql.CurrencyIsoCode;
            coql.Higher_Level_Item__c 				= ql.Higher_Level_Item__c;
            coql.Labor_Cost__c 						= ql.Labor_Cost__c;
            coql.Line_Expected_Booking__c 			= ql.Line_Expected_Booking__c;
            /*if(changeOrderOppQuoteMap.get(ql.Quote__c).Opportunity_Type__c <> NULL 
               && changeOrderOppQuoteMap.get(ql.Quote__c).Opportunity_Type__c == 'Change Order - Credit'
               && coql.Line_Expected_Booking__c <> NULL && coql.Line_Expected_Booking__c > 0)
            {
                coql.Line_Expected_Booking__c = coql.Line_Expected_Booking__c * -1;
            }*/
            coql.Line_Item_Description__c 			= ql.Line_Item_Description__c;
            coql.List_Price_per_unit__c 			= ql.List_Price__c;
            coql.Material_Type__c 					= ql.Material_Type__c;
            coql.Overhead_Cost__c 					= ql.Overhead_Cost__c;
            coql.Par_Location__c 					= ql.Par_Location__c;
            coql.Part_of_a_Bundle__c 				= ql.Part_of_a_Bundle__c;
            coql.Pricing_Reference_Model__c 		= ql.Pricing_Reference_Model__c;
            coql.Product_Code__c 					= ql.Product_Code__c;
            coql.Product_Cost__c 					= ql.Product_Cost__c;
            coql.Quantity__c 						= ql.Quantity__c;
            coql.Requested_Delivery_Date__c 		= ql.Requested_Delivery_Date__c;
            coql.SAP_Line_Item_GUID__c 				= ql.SAP_Line_Item_GUID__c;
            coql.SAP_Line_Number__c 				= ql.SAP_Line_Number__c;
            coql.SAP_NPV__c 						= ql.SAP_NPV__c;
            coql.Total_Cost__c 						= ql.Total_Cost2__c;
            coql.Derived_Portfolio_Segment__c		= getDerivedProtfolio(ql);
            coql.Quote_Number__c					= ql.SAP_Quote_Number__c;
            changeOrderQLUpsertList.add(coql);
        }
        
        if(!changeOrderQLUpsertList.isEmpty())
        {
            upsert changeOrderQLUpsertList;
            
            Map<Id, Change_Order_Tableau__c> cotExistingMap = new Map<Id, Change_Order_Tableau__c>();
            
            for(Change_Order_Tableau__c cot : [SELECT id, Change_Order_Quote_Line__c 
                                               FROM Change_Order_Tableau__c 
                                               WHERE Change_Order_Quote_Line__c IN :changeOrderQLUpsertList])
            {
                cotExistingMap.put(cot.Change_Order_Quote_Line__c, cot);
            }
            
            /**START**** Inserting Debit and Omnicell Opoortunity type Quote lines into Change_Order_Tableau__c object*****/
            for(Change_Order_Quote_Line__c coql : [SELECT Id,SAP_Line_Number__c,Higher_Level_Item__c,Quantity__c,SAP_NPV__c,Line_Expected_Booking__c,
                                                   Total_Cost__c,Overhead_Cost__c,Product_Cost__c,Labor_Cost__c,Product_Code__c,Pricing_Reference_Model__c,
                                                   Line_Item_Description__c,Par_Location__c,Part_of_a_Bundle__c,Material_Type__c,List_Price_per_unit__c,
                                                   Requested_Delivery_Date__c,Change_order_Opportunity__r.Opportunity_Closed_Date_Quater__c ,SALESORDER_NUM__c,
                                                   Change_order_Opportunity__r.Opportunity_Expected_Close_Date__c,Change_order_Opportunity__r.Opportunity_Number__c,
                                                   Change_order_Opportunity__r.Opportunity_Type__c,Change_order_Opportunity__r.Primary_Quote_Number__c ,
                                                   Quote_Line__r.Product__r.Portfolio_Segment__c, Derived_Portfolio_Segment__c, Account_CSN__c ,Account_Name__c ,Quote_Order_Type__c,
                                                   Top_Level_Account_Name__c , Top_Level_Account_CSN__c, Change_Order_Opportunity__r.Top_Level_Opportunity_Closed_Date_Quater__c,
                                                   Change_Order_Opportunity__r.Top_Level_Opportunity_Closed_Date__c, Change_Order_Opportunity__r.Top_Level_Opportunity_Number__c,
                                                   Change_Order_Opportunity__r.Opportunity_Expected_Bookings__c, Parent_Key__c, SAP_Line_Item_GUID__c, Top_Level_Primary_Quote_Number__c,
                                                   CurrencyIsoCode, Currency__c, Status__c, Quote_Line__c, Change_Order_Opportunity__c,
                                                   Quote_Line__r.quote__r.Associated_Sales_Order__c, Change_Order_Opportunity__r.Opportunity__r.owner.name
                                                   FROM Change_Order_Quote_Line__c 
                                                   WHERE Id IN :changeOrderQLUpsertList])
            {
                Change_Order_Tableau__c cot = new Change_Order_Tableau__c();
                
                cot.Change_Order_Quote_Line__c = coql.Id;
                
                if(cotExistingMap.containsKey(cot.Change_Order_Quote_Line__c))
                {
                	cot.id = cotExistingMap.get(cot.Change_Order_Quote_Line__c).Id;    
                }
                else
                {
                    cot.New_Record__c = true;
                }
                
                cot.SAP_Line_Number__c = coql.SAP_Line_Number__c;
                cot.Higher_Level_Item__c = coql.Higher_Level_Item__c;
                cot.Quantity__c = coql.Quantity__c;
                cot.SAP_NPV__c = coql.SAP_NPV__c;
                cot.Line_Expected_Booking__c = coql.Line_Expected_Booking__c;
                cot.Total_Cost__c = coql.Total_Cost__c;
                cot.Overhead_Cost__c = coql.Overhead_Cost__c;
                cot.Product_Cost__c = coql.Product_Cost__c;
                cot.Labor_Cost__c = coql.Labor_Cost__c;
                cot.Product_Code__c = coql.Product_Code__c;
                cot.Pricing_Reference_Model__c = coql.Pricing_Reference_Model__c;
                cot.Par_Location__c = coql.Par_Location__c;
                cot.Part_of_a_Bundle__c = coql.Part_of_a_Bundle__c;
                cot.Material_Type__c = coql.Material_Type__c;
                cot.List_Price_per_unit__c = coql.List_Price_per_unit__c;
                cot.Requested_Delivery_Date__c = coql.Requested_Delivery_Date__c;
                cot.SALESORDER_NUM__c = coql.SALESORDER_NUM__c;
                cot.Opportunity_Closed_Date_Quater__c  = coql.Change_order_Opportunity__r.Opportunity_Closed_Date_Quater__c ;
                cot.Opportunity_Close_Date__c = coql.Change_order_Opportunity__r.Opportunity_Expected_Close_Date__c;
                cot.Opportunity_Number__c = coql.Change_order_Opportunity__r.Opportunity_Number__c;
                cot.Opportunity_Type__c = coql.Change_order_Opportunity__r.Opportunity_Type__c;
                cot.Primary_Quote_Number__c = coql.Change_order_Opportunity__r.Primary_Quote_Number__c;
                cot.Portfolio_Segment__c = coql.Quote_Line__r.Product__r.Portfolio_Segment__c;
                cot.DerivedPortfolioSegment__c = coql.Derived_Portfolio_Segment__c;
                cot.Account_CSN__c = coql.Account_CSN__c ;
                cot.Account_Name__c = coql.Account_Name__c;
                cot.Quote_Order_Type__c = coql.Quote_Order_Type__c;
                cot.Top_Level_Account_Name__c =coql.Top_Level_Account_Name__c; 
                cot.Top_Level_Account_CSN__c = coql.Top_Level_Account_CSN__c;
                
                if(coql.Quote_Line__r.Product__r.Portfolio_Segment__c == 'Anesthesia Workstation'
                   || coql.Quote_Line__r.Product__r.Portfolio_Segment__c == 'Automated Dispensing Cabinets'
                   || coql.Quote_Line__r.Product__r.Portfolio_Segment__c == 'Supply')
                {
                    cot.Point_Of_Care__c = true; 
                }
                if(coql.Change_Order_Opportunity__r.Top_Level_Opportunity_Closed_Date_Quater__c <> NULL)
                {
                    cot.TopOpportunityClosedDateQuarter__c = coql.Change_Order_Opportunity__r.Top_Level_Opportunity_Closed_Date_Quater__c;
                    cot.TopOpportunityExpectedCloseDate__c = coql.Change_Order_Opportunity__r.Top_Level_Opportunity_Closed_Date__c;
                    cot.TopOpportunityNumber__c = coql.Change_Order_Opportunity__r.Top_Level_Opportunity_Number__c;
                }
                else
                {
                    cot.TopOpportunityClosedDateQuarter__c = cot.Opportunity_Closed_Date_Quater__c;
                    cot.TopOpportunityExpectedCloseDate__c = cot.Opportunity_Close_Date__c;
                    cot.TopOpportunityNumber__c = cot.Opportunity_Number__c;
                }
                if(coql.Change_Order_Opportunity__r.Opportunity_Expected_Bookings__c <> NULL)
                {
                    cot.Opportunity_Expected_Bookings__c = coql.Change_Order_Opportunity__r.Opportunity_Expected_Bookings__c;
                }
                
                cot.Line_Item_Description__c = coql.Line_Item_Description__c;
                cot.Parent_Key__c = coql.Parent_Key__c;
                cot.SAP_Line_Item_GUID__c = coql.SAP_Line_Item_GUID__c;
                cot.Top_Level_Primary_Quote_Number__c = coql.Top_Level_Primary_Quote_Number__c;
                cot.CurrencyIsoCode = coql.CurrencyIsoCode;
                cot.Currency__c = coql.Currency__c;
                cot.Change_Order_Opportunity__c = coql.Change_Order_Opportunity__c;
                cot.Quote_Line__c = coql.Quote_Line__c;
                cot.Associated_Sales_Order__c = coql.Quote_Line__r.quote__r.Associated_Sales_Order__c;
                if(coql.Change_Order_Opportunity__r.Opportunity__r.owner.name <> NULL && coql.Change_Order_Opportunity__r.Opportunity__r.owner.name <> '')
                {
                    cot.OppOwnerName__c = coql.Change_Order_Opportunity__r.Opportunity__r.owner.name;
                }
                cotUpsertList.add(cot);
            }
            
            if(!cotUpsertList.isEmpty())
                upsert cotUpsertList;
            /**END****** Inserting Debit and Omnicell Opoortunity type Quote lines into Change_Order_Tableau__c object*****/
        }
    }
    
    global void finish(Database.BatchableContext BC)
    {
        system.debug('inside final Quote Line Insert batch');
        if(batchType == 'checkQuoteLineDate')
        {
            database.executeBatch(new ChangeOrderQuoteLineBatch('checkQuoteLineDate'), 1000);
        }
        else
        {
            ChangeOrderChildOpportunitiesBatch.upsertBatchLastRunTime('ChangeOrderQuoteLineBatch');
            database.executeBatch(new ChangeOrderDeleteQuoteKey(),10000);
            database.executeBatch(new ChangeOrderDeleteBacklogStatus(),10000);
        }
    }
    
    public static String getDerivedProtfolio(Quote_Line__c line)
    {
        String derivedPortSegment 			= 'Others';
        String productPortfolioSegment 		= line.Product__r.Portfolio_Segment__c;
        String orderType 					= line.Quote__r.Order_Type__c;
        String quoteStatus 					= line.Quote__r.Status;
        String oppGroup 					= line.Quote__r.Opportunity.OpportunityGroup__c;
        String productType 					= line.Product__r.SAP_Product_Type__c;
        String oppType 					    = line.Quote__r.Opportunity.Opportunity__c;//IBA-5787 Saptarsha Panthi
        
        if(orderType == 'ZORB' || orderType == 'ZORX')
        {
            derivedPortSegment = 'Consumables / Core Machines';
        }
        else if((quoteStatus == 'E0024' || oppGroup == 'Advanced Services' || oppType =='Adv Svc Renewal' || orderType == 'ZQRS')
                || productPortfolioSegment == 'Services' || productPortfolioSegment == 'Central Pharmacy Dispensing Service'   //IBA-4331
                || productPortfolioSegment == 'IV Compounding Service' || productPortfolioSegment == 'IV Legacy'
                || productPortfolioSegment == 'IVX Workflow') //IBA-5787 updated if condition with oppType =='Adv Svc Renewal' Saptarsha Panthi
        {
            derivedPortSegment = 'Advanced Services';
        }
        else if(productType  == 'Subscription')
        {
            derivedPortSegment = 'Subscriptions';
        }
        else if(productPortfolioSegment == 'MA Consumable' || productPortfolioSegment == 'Core Machine' 
                || productPortfolioSegment == 'MA Raw/MA tooling' || productPortfolioSegment == 'MultiMed Automation'
                || productPortfolioSegment == 'Packagers' || productPortfolioSegment == 'SingleDose Automation' || productPortfolioSegment == 'Acute Consumable')
        {
            derivedPortSegment = 'Consumables / Core Machines';
        }
        else if(productPortfolioSegment == 'Cloud Hosted OmniCenter' || productPortfolioSegment == 'Infrastructure' 
                || productPortfolioSegment == 'Inventory Optimization Service and Platform')  //IBA-4331
        {
            derivedPortSegment = 'Infrastructure / Shared';
        }
        else if(productPortfolioSegment == 'Carousels' || productPortfolioSegment == 'Central Pharmacy' 
                || productPortfolioSegment == 'Central Pharmacy Legacy')
        {
            derivedPortSegment = 'Central Pharmacy';
        }
        else if(productPortfolioSegment == 'Anesthesia Workstation' || productPortfolioSegment == 'Automated Dispensing Cabinets' 
                || productPortfolioSegment == 'Supply')
        {
            derivedPortSegment = 'Automated Dispensing Cabinets';
        }
        
        return derivedPortSegment;
    }
}