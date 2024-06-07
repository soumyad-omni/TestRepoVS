public without sharing class CopyConfigFromQuoteCtrl 
{
    @AuraEnabled
    public static list<Quote_Line__c> searchQuote(string quoteNum, string sourceQuoteId){
        return [SELECT Id,Name,Par_Location__c,Quote__c,Quantity__c,Product_Code__c,Product__c,Add_to_cart__c, Interim_flag__c FROM Quote_Line__c 
                WHERE Quote__r.SAP_Quote_Number_Truncated__c = :quoteNum AND Quote__c != :sourceQuoteId AND 
                Product_Code__c!='FREIGHT' AND Add_to_cart__c = true ORDER BY Par_Location__c];
    }
    @AuraEnabled
    public static void copyQuoteLines(string sourceQuoteId, list<Quote_Line__c> quoteLinesToCopy){
        Map<string,Map<string,Quote_Line__c>> quoteParLocationMap = new Map<string,Map<string,Quote_Line__c>>();
        Set<String> fieldNames = Quote_Line__c.sObjectType.getDescribe().fields.getMap().keySet();
        
        for(Quote_Line__c qlObj : Database.query('SELECT Par_Location__c,Quote__c,Quantity__c,Product__c,Product_Code__c,Add_to_cart__c FROM Quote_Line__c WHERE Par_Location__c!=null AND Quote__c=:sourceQuoteId AND Add_to_cart__c = true'))
        {
            if(!quoteParLocationMap.containskey(qlObj.Par_Location__c))
            {
                quoteParLocationMap.put(qlObj.Par_Location__c, new Map<string,Quote_Line__c>());
            }
            quoteParLocationMap.get(qlObj.Par_Location__c).put(qlObj.Product_Code__c, qlObj);
        }
        
        list<Quote_Line__c> quoteLinesToCreate = new list<Quote_Line__c>();
        list<Quote_Line__c> quoteLinesToUpdate = new list<Quote_Line__c>();
        Quote_Line__c tempQuoteLine = new Quote_Line__c();
        for(Quote_Line__c qLine: quoteLinesToCopy){
            if(quoteParLocationMap.containsKey(qLine.Par_Location__c) && quoteParLocationMap.get(qLine.Par_Location__c).containsKey(qLine.Product_Code__c)){
                tempQuoteLine = quoteParLocationMap.get(qLine.Par_Location__c).get(qLine.Product_Code__c);
                tempQuoteLine.Quantity__c += qLine.Quantity__c;
                tempQuoteLine.Interim_flag__c = true;
                quoteLinesToUpdate.add(tempQuoteLine);
            }else{
                tempQuoteLine = qLine.clone();
                tempQuoteLine.Quote__c = sourceQuoteId;
                tempQuoteLine.Interim_flag__c = true;
                quoteLinesToCreate.add(tempQuoteLine);
            }
        }
        try
        {
            Quote_Line__c freightLineRecord = addFreightLineRecord(sourceQuoteId);
            if(new Quote_Line__c() != freightLineRecord){
                quoteLinesToCreate.add(freightLineRecord);
            }
            system.debug('quoteLinesToCreate--'+quoteLinesToCreate);
            system.debug('quoteLinesToUpdate--'+quoteLinesToUpdate);
            if(!quoteLinesToCreate.isEmpty())
            {
                insert quoteLinesToCreate;
            }
            if(!quoteLinesToUpdate.isEmpty())
            {
                update quoteLinesToUpdate;
            }
        }catch(DMLException ex)
        {
            system.debug('Exception--'+ex.getStackTraceString());
            throw new AuraHandledException(ex.getDmlMessage(0));
        }
    }
    
    public static Quote_Line__c addFreightLineRecord(String qid) {
        List<Quote_Line__c> freightQuoteLines = new List<Quote_Line__c>(); 
        freightQuoteLines = [Select id,Product__r.productcode from Quote_Line__c 
                             where Quote__c =: qid and Product__r.productcode = 'FREIGHT'];
        Quote_Line__c quoteLine = new Quote_Line__c();
        if (freightQuoteLines.size() == 0 ) 
        {
            Product2 pr1 = [Select id,ProductCode,Description from Product2 where ProductCode = 'FREIGHT'];
        quoteLine.RecordTypeId = '0121N000001M5AGQA0';
        quoteLine.Quote__c = qid;
        quoteLine.Product__c = pr1.id;
        quoteLine.Quantity__c = 1;
        quoteLine.Unit_of_Measure__c = 'EA';
        //quoteLine.SAP_Line_Number__c = 100;
        quoteLine.SAP_Line_Number__c = 300;
        quoteLine.Line_Status__c='E0001';
        //quoteLine.External_Config__c=true;
        quoteline.Add_to_cart__c = True;
        quoteline.Interim_flag__c = True;
        //quoteLine.SAP_Line_Item_GUID__c = generateRamdonNumber();
        return quoteLine;
        }
        return quoteLine;
    }
}