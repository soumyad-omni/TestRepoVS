public without sharing class CopyMoveToParController 
{
    @AuraEnabled
    public static list<Quote_Line__c> fetchQuoteLines(string parLocation, Id quoteId)
    { 
        system.debug('parLocation---'+parLocation);
        system.debug('quoteId---'+quoteId);
        return [SELECT Id,Name,Par_Location__c,Quote__c,Product__r.Name,Product_Code__c,Quantity__c,Higher_Level_Item__c,SAP_Line_Number__c FROM Quote_Line__c WHERE Par_Location__c=:parLocation AND Quote__c=:quoteId AND Add_to_cart__c =true]; 
    }
    @AuraEnabled
    public static list<Quote_Line__c> copyMovePars(list<Quote_Line__c> quoteLines, list<string> selectedPars, string parLocation, Id quoteId, string copyMove)
    { 
        system.debug('parLocation---'+parLocation);
        system.debug('quoteId---'+quoteId);
        system.debug('quoteLines---'+quoteLines);
        system.debug('selectedPars---'+selectedPars);
        system.debug('copyMove---'+copyMove);
        
        list<Quote_Line__c> quoteLinesTemp = new list<Quote_Line__c>();
        set<decimal> highLevelItems = new set<decimal>();
        for(Quote_Line__c ql : quoteLines){
            highLevelItems.add(ql.SAP_Line_Number__c);
        }
        system.debug('highLevelItems---'+highLevelItems);
        Map<string,Map<string,Quote_Line__c>> quoteParLocationMap = new Map<string,Map<string,Quote_Line__c>>();
        Set<String> fieldNames = Quote_Line__c.sObjectType.getDescribe().fields.getMap().keySet();
        
        for(Quote_Line__c qlObj : Database.query('SELECT ' + string.join(new list<string>(fieldNames), ',') + ' FROM Quote_Line__c WHERE Par_Location__c!=null AND Quote__c=:quoteId'))
        {
            if(!quoteParLocationMap.containskey(qlObj.Par_Location__c))
            {
                quoteParLocationMap.put(qlObj.Par_Location__c, new Map<string,Quote_Line__c>());
            }
            quoteParLocationMap.get(qlObj.Par_Location__c).put(qlObj.Product_Code__c, qlObj);
            
            if((copyMove == 'Move' && (highLevelItems.contains(qlObj.Higher_Level_Item__c) || highLevelItems.contains(qlObj.SAP_Line_Number__c))) || 
               (copyMove != 'Move' && highLevelItems.contains(qlObj.SAP_Line_Number__c))){
                quoteLinesTemp.add(qlObj);
            }
        }
        system.debug('quoteLinesTemp--size--'+quoteLinesTemp.size());
        list<Quote_Line__c> quoteLinesToCreate = new list<Quote_Line__c>();
        list<Quote_Line__c> quoteLinesToUpdate = new list<Quote_Line__c>();
        list<Quote_Line__c> quoteLinesToDelete = new list<Quote_Line__c>();
        
        for(string parName : selectedPars)
        {
            if(parLocation != parName)
            {
                for(Quote_Line__c ql : quoteLinesTemp)
                {
                    Quote_Line__c newQuoteLine = new Quote_Line__c();
                    if(quoteParLocationMap.containskey(parName) && quoteParLocationMap.get(parName).containskey(ql.Product_Code__c))
                    {
                        //update the quantity for same product code quoteline
                        newQuoteLine = quoteParLocationMap.get(parName).get(ql.Product_Code__c);
                        newQuoteLine.Quantity__c += ql.Quantity__c;
                        newQuoteLine.Interim_flag__c = true;
                        quoteLinesToUpdate.add(newQuoteLine);
                        if(copyMove == 'Move' &&  highLevelItems.contains(ql.SAP_Line_Number__c) )
                        {
                            ql.Cart_Item_to_Delete__c = true;
                            ql.Interim_flag__c = true;
                            quoteLinesToUpdate.add(ql);
                            //quoteLinesToDelete.add(ql);
                        }
                    }else if(copyMove != 'Move')
                    {
                        newQuoteLine = quoteParLocationMap.get(ql.Par_Location__c).get(ql.Product_Code__c).clone();
                        newQuoteLine.Key__c=null;
                        newQuoteLine.SAP_Line_Number__c = null;
                        newQuoteLine.SAP_Line_Item_GUID__c = null;
                        newQuoteLine.Par_Location__c = parName;
                        newQuoteLine.Interim_flag__c = True;
                        quoteLinesToCreate.add(newQuoteLine);
                    }else
                    {
                        ql.Par_Location__c = parName;
                        ql.Interim_flag__c = true;
                        quoteLinesToUpdate.add(ql);
                    }
                }
            }
        }
        try
        {
            system.debug('quoteLinesToCreate--size--'+quoteLinesToCreate.size()+'--'+quoteLinesToCreate);
            system.debug('quoteLinesToUpdate--size--'+quoteLinesToUpdate.size()+'--'+quoteLinesToUpdate);
            system.debug('quoteLinesToDelete--size--'+quoteLinesToDelete.size()+'--'+quoteLinesToDelete);
            if(!quoteLinesToCreate.isEmpty())
            {
                insert quoteLinesToCreate;
            }
            if(!quoteLinesToUpdate.isEmpty())
            {
                update quoteLinesToUpdate;
            }
            if(!quoteLinesToDelete.isEmpty())
            {
                //delete quoteLinesToDelete;
            } 
        }catch(DMLException ex)
        {
            system.debug('Exception--'+ex.getStackTraceString());
            throw new AuraHandledException(ex.getDmlMessage(0));
        }
        return fetchQuoteLines(parLocation, quoteId);
    }
}