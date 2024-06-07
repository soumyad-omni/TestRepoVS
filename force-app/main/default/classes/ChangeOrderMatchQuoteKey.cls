global class ChangeOrderMatchQuoteKey implements Database.Batchable<sObject>, Database.Stateful 
{
    private string keyConsider = '';
    public ChangeOrderMatchQuoteKey(String keyLength)
    {
        keyConsider = keyLength;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        String query 	= 'SELECT id, Quote_Line__r.Quote__c, Quote_Line__r.Par_Location__c, Quote_Line__r.Product_Code__c,';
        query			= query + ' Quote_Line__r.Quantity__c, Quote_Line__r.Line_Expected_Booking__c, Change_Order_Opportunity__c, ';
        query			= query + ' Quote_Line__r.Pricing_Reference_Model__c, Quote_Line__r.Pricing_Reference_Model__r.ProductCode';
        query			= query + ' FROM Change_Order_Quote_Line__c';
        query			= query + ' WHERE Change_Order_Opportunity__r.Opportunity_Type__c = \'Change Order - Credit\'';
        if(keyConsider == 'halfkey')
        {
            query		= query + ' AND Top_Level_Quote_Line__c = NULL';
        }
        //query			= query + ' AND Change_Order_Opportunity__r.Primary_Quote__c = \'0Q03l000001upZqCAI\'';

        system.debug('query-->'+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Change_Order_Quote_Line__c> coqlList) 
    {
        Set<id> quoteIds = new Set<Id>();
        List<id> changeOrderOppIds = new List<Id>();
        Map<Id, List<Change_Order_Credit_Key__c>> keyMap = new Map<Id, List<Change_Order_Credit_Key__c>>();
        Map<Id, List<Id>> changeOrderOppQuoteMap = new Map<Id, List<Id>>();
        for(Change_Order_Quote_Line__c coql : coqlList)
        {
            changeOrderOppIds.add(coql.Change_Order_Opportunity__c);
        }
        
        List<Change_Order_Opportunity__c> cooList = [SELECT id, 
                                                     Associated_Opportunity__c, Associated_Opportunity__r.PrimaryQuote__c,
                                                     Associated_Opportunity__r.Associated_Opportunity__c, Associated_Opportunity__r.Associated_Opportunity__r.PrimaryQuote__c,
                                                     Associated_Opportunity__r.Associated_Opportunity__r.Associated_Opportunity__c, Associated_Opportunity__r.Associated_Opportunity__r.Associated_Opportunity__r.PrimaryQuote__c,
                                                     Associated_Opportunity__r.Associated_Opportunity__r.Associated_Opportunity__r.Associated_Opportunity__c, Associated_Opportunity__r.Associated_Opportunity__r.Associated_Opportunity__r.Associated_Opportunity__r.PrimaryQuote__c,
                                                     Associated_Opportunity__r.Associated_Opportunity__r.Associated_Opportunity__r.Associated_Opportunity__r.Associated_Opportunity__c, Associated_Opportunity__r.Associated_Opportunity__r.Associated_Opportunity__r.Associated_Opportunity__r.Associated_Opportunity__r.PrimaryQuote__c
                                                     FROM Change_Order_Opportunity__c
                                                     WHERE id IN :changeOrderOppIds];
        
        for(Change_Order_Opportunity__c coo : cooList)
        {
            system.debug('coo.Associated_Opportunity__c-->'+coo.Associated_Opportunity__c);
            if(coo.Associated_Opportunity__c <> NULL)
            {
                List<Id> changeOrderOppQuotes = new List<id>();
                system.debug('coo.Associated_Opportunity__r.PrimaryQuote__c-->'+coo.Associated_Opportunity__r.PrimaryQuote__c);
                quoteIds.add(coo.Associated_Opportunity__r.PrimaryQuote__c);
                changeOrderOppQuotes.add(coo.Associated_Opportunity__r.PrimaryQuote__c);
                system.debug('coo.Associated_Opportunity__r.Associated_Opportunity__c-->'+coo.Associated_Opportunity__r.Associated_Opportunity__c);
                if(coo.Associated_Opportunity__r.Associated_Opportunity__c <> NULL)
                {
                    system.debug('coo.Associated_Opportunity__r.Associated_Opportunity__r.PrimaryQuote__c-->'+coo.Associated_Opportunity__r.Associated_Opportunity__r.PrimaryQuote__c);
                    quoteIds.add(coo.Associated_Opportunity__r.Associated_Opportunity__r.PrimaryQuote__c);
                    changeOrderOppQuotes.add(coo.Associated_Opportunity__r.Associated_Opportunity__r.PrimaryQuote__c);
                    system.debug('coo.Associated_Opportunity__r.Associated_Opportunity__r.Associated_Opportunity__c-->'+coo.Associated_Opportunity__r.Associated_Opportunity__r.Associated_Opportunity__c);
                    if(coo.Associated_Opportunity__r.Associated_Opportunity__r.Associated_Opportunity__c <> NULL)
                    {
                        system.debug('coo.Associated_Opportunity__r.Associated_Opportunity__r.Associated_Opportunity__r.PrimaryQuote__c-->'+coo.Associated_Opportunity__r.Associated_Opportunity__r.Associated_Opportunity__r.PrimaryQuote__c);
                        quoteIds.add(coo.Associated_Opportunity__r.Associated_Opportunity__r.Associated_Opportunity__r.PrimaryQuote__c);
                        changeOrderOppQuotes.add(coo.Associated_Opportunity__r.Associated_Opportunity__r.Associated_Opportunity__r.PrimaryQuote__c);
                        
                        if(coo.Associated_Opportunity__r.Associated_Opportunity__r.Associated_Opportunity__r.Associated_Opportunity__c <> NULL)
                        {
                            system.debug('coo.Associated_Opportunity__r.Associated_Opportunity__r.Associated_Opportunity__r.Associated_Opportunity__r.PrimaryQuote__c-->'+coo.Associated_Opportunity__r.Associated_Opportunity__r.Associated_Opportunity__r.Associated_Opportunity__r.PrimaryQuote__c);
                            quoteIds.add(coo.Associated_Opportunity__r.Associated_Opportunity__r.Associated_Opportunity__r.Associated_Opportunity__r.PrimaryQuote__c);
                            changeOrderOppQuotes.add(coo.Associated_Opportunity__r.Associated_Opportunity__r.Associated_Opportunity__r.Associated_Opportunity__r.PrimaryQuote__c);
                            
                            if(coo.Associated_Opportunity__r.Associated_Opportunity__r.Associated_Opportunity__r.Associated_Opportunity__r.Associated_Opportunity__c <> NULL)
                            {
                                system.debug('coo.Associated_Opportunity__r.Associated_Opportunity__r.Associated_Opportunity__r.Associated_Opportunity__r.Associated_Opportunity__r.PrimaryQuote__c-->'+coo.Associated_Opportunity__r.Associated_Opportunity__r.Associated_Opportunity__r.Associated_Opportunity__r.Associated_Opportunity__r.PrimaryQuote__c);
                                quoteIds.add(coo.Associated_Opportunity__r.Associated_Opportunity__r.Associated_Opportunity__r.Associated_Opportunity__r.Associated_Opportunity__r.PrimaryQuote__c);
                                changeOrderOppQuotes.add(coo.Associated_Opportunity__r.Associated_Opportunity__r.Associated_Opportunity__r.Associated_Opportunity__r.Associated_Opportunity__r.PrimaryQuote__c);
                            }
                        }
                    }
                }
                
                changeOrderOppQuoteMap.put(coo.Id, changeOrderOppQuotes);
            }
        }
        system.debug('quoteIds-->'+quoteIds);
        
        Map<String,Id> tempmap = new Map<String, Id>();
        for(Change_Order_Credit_Key__c key : [SELECT quote__c, key__c FROM Change_Order_Credit_Key__c WHERE quote__c IN :quoteIds])
        {
            List<String> quoteLineKeyList = key.key__c.split('newql');
            
            for(String eachKey : quoteLineKeyList)
            {
                List<String> keyQLSplit = eachKey.split('qlid');
                if(keyConsider == 'fullkey')
                    tempmap.put(key.quote__c+''+(keyQLSplit[0].replace('halfkey','')),keyQLSplit[1]);
                else if(keyConsider == 'halfkey')
                    tempmap.put(key.quote__c+''+(keyQLSplit[0].split('halfkey')[0]),keyQLSplit[1]);
            }
        }
        
        for(Change_Order_Quote_Line__c coql : coqlList)
        {
            String quoteLineKey		= (coql.Quote_Line__r.Par_Location__c == NULL ? '' : coql.Quote_Line__r.Par_Location__c);
            quoteLineKey 			= quoteLineKey + (coql.Quote_Line__r.Pricing_Reference_Model__c == NULL ? '' + coql.Quote_Line__r.Product_Code__c : '' + coql.Quote_Line__r.Pricing_Reference_Model__r.ProductCode);
            if(keyConsider == 'fullkey')
            {
                quoteLineKey		= quoteLineKey + (coql.Quote_Line__r.Quantity__c == NULL ? '' : '' + coql.Quote_Line__r.Quantity__c);
                quoteLineKey		= quoteLineKey + (coql.Quote_Line__r.Line_Expected_Booking__c == NULL ? '' : '' + coql.Quote_Line__r.Line_Expected_Booking__c);
            }
            
            if(changeOrderOppQuoteMap.containsKey(coql.Change_Order_Opportunity__c))
            {
                for(Id changeOrderOppQuoteId : changeOrderOppQuoteMap.get(coql.Change_Order_Opportunity__c))
                {
                    if(tempmap.containsKey(changeOrderOppQuoteId+''+quoteLineKey))
                    {
                        coql.Top_Level_Quote_Line__c = tempmap.get(changeOrderOppQuoteId+''+quoteLineKey);
                    }
                }
            }
        }
        
        update coqlList;
    }
    
    global void finish(Database.BatchableContext BC)
    {
        if(keyConsider == 'fullkey')
        {
            database.executeBatch(new ChangeOrderMatchQuoteKey('halfkey'));
        }
        
        system.debug('inside final ChangeOrderMatchQuoteKey batch');
    }
}