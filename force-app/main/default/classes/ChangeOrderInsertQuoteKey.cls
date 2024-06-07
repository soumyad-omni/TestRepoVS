global class ChangeOrderInsertQuoteKey implements Database.Batchable<sObject>, Database.Stateful 
{
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        String query 	= 'SELECT id ';
        query			= query + ' FROM quote';
        query			= query + ' WHERE opportunity.Opportunity__c IN (\'Change Order - Credit\' , \'Change Order - Debit\',\'Omnicell Opportunity\')';
        query			= query + ' AND Primary_Quote__c = TRUE';
        query 			= query + ' AND opportunity.StageName = \'6 Closed Won\'';
        query 			= query + ' AND opportunity.OppStatus__c in (\'Booked with No PO\',\'Booked with No Product PO\',\'Booked with No Service PO\',\'Non Comm. Book - No Service PO\',\'Commissionable - No Service PO\',\'Fully Booked\',\'Non Comissionable Booking\')';
        query			= query + ' AND opportunity.RecordType.DeveloperName IN (\'NAA_Opportunity\',\'US_Canada_Advanced_Services\',\'US_Canada_Specialty\')'; //IBA-5024
        query			= query + ' AND (NOT opportunity.account.name like \'%omnicell%\')';
        //query			= query + ' AND id IN (\'0Q01N000001m64n\')';
        system.debug('query-->'+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<quote> quoteList) 
    {
        Map<Id, List<Change_Order_Credit_Key__c>> keyMap = new Map<Id, List<Change_Order_Credit_Key__c>>();
        
        for(Change_Order_Credit_Key__c key : [SELECT id, Quote__c, Key__c 
                                              FROM Change_Order_Credit_Key__c
                                              WHERE Quote__c IN :quoteList
                                              ORDER BY createddate])
        {
            if(keyMap.containsKey(key.Quote__c))
            {
                List<Change_Order_Credit_Key__c> keyList = keyMap.get(key.Quote__c);
                keyList.add(key);
                keyMap.put(key.Quote__c,keyList);
            }
            else
            {
                keyMap.put(key.Quote__c, new List<Change_Order_Credit_Key__c>{key});
            }
        }
        
        List<Quote_Line__c> qlList = [SELECT id, Par_Location__c, Product_Code__c, Quantity__c, Line_Expected_Booking__c,
                                      Pricing_Reference_Model__c, Pricing_Reference_Model__r.ProductCode, Quote__c
                                      FROM Quote_Line__c
                                      WHERE Quote__c IN :quoteList];
        
        for(Quote_Line__c ql : qlList)
        {
            
            String quoteLineKey		= (ql.Par_Location__c == NULL ? '' : ql.Par_Location__c);
            quoteLineKey 			= quoteLineKey + (ql.Pricing_Reference_Model__c == NULL ? '' + ql.Product_Code__c : '' + ql.Pricing_Reference_Model__r.ProductCode);
            quoteLineKey			= quoteLineKey + 'halfkey';
            quoteLineKey			= quoteLineKey + (ql.Quantity__c == NULL ? '' : '' + ql.Quantity__c);
            quoteLineKey			= quoteLineKey + (ql.Line_Expected_Booking__c == NULL ? '' : '' + ql.Line_Expected_Booking__c * -1);
            quoteLineKey			= quoteLineKey + 'qlid' + ql.Id;
            
            if(keyMap.containsKey(ql.Quote__c))
            {
                Boolean createNew = true;
                List<Change_Order_Credit_Key__c> keyList = keyMap.get(ql.Quote__c);
                
                for(Change_Order_Credit_Key__c oldkey : keyList)
                {
                    if(oldkey.Key__c == NULL || (oldkey.Key__c.length()+quoteLineKey.length()) <= 130000)
                    {
                        oldkey.Key__c = (oldkey.Key__c == NULL ? '' : oldkey.Key__c + 'newql') + quoteLineKey;
                        createNew = false;
                        break;
                    }
                }
                
                if(createNew)
                {
                    Change_Order_Credit_Key__c newkey =  new Change_Order_Credit_Key__c();
                    newkey.Quote__c = ql.Quote__c;
                    newkey.Key__c = quoteLineKey;
                    keyList.add(newkey);
                    keyMap.put(ql.Quote__c, keyList);
                }
            }
            else
            {
                Change_Order_Credit_Key__c key =  new Change_Order_Credit_Key__c();
                key.Quote__c = ql.Quote__c;
                key.Key__c = quoteLineKey;
                keyMap.put(ql.Quote__c, new List<Change_Order_Credit_Key__c>{key});
            }
        }
        
        if(!keyMap.isEmpty())
        {
            List<Change_Order_Credit_Key__c> upsertList = new List<Change_Order_Credit_Key__c>();
            
            for(List<Change_Order_Credit_Key__c> keyList : keyMap.values())
            {
                for(Change_Order_Credit_Key__c key : keyList)
                {
                    upsertList.add(key);
                }
            }
            
            if(!upsertList.isEmpty())
            {
                upsert upsertList;
            }
        }
    }
    
    global void finish(Database.BatchableContext BC)
    {
        system.debug('inside final ChangeOrderQuoteKey batch');
        database.executeBatch(new ChangeOrderMatchQuoteKey('fullkey'));
    }
}