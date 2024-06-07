trigger QuoteLineDimensionTrigger on Quote_Line_Dimension__c (before insert) {
    system.debug('santu');
    List<String> guidList = new List<String>();
    Map<String, String> guidQuoteLineMap = new Map<String, String>();
    
    for(Quote_Line_Dimension__c qld : trigger.new)
    {
        if(qld.Excel_GUID__C <> NULL && qld.Excel_GUID__C <> '')
        {
            guidList.add(qld.Excel_GUID__C);
        }
    }
    
    if(guidList.size() > 0)
    {
        for(Quote_Line__c ql : [SELECT id, SAP_Line_Item_GUID__c FROM Quote_Line__c WHERE SAP_Line_Item_GUID__c IN :guidList])
        {
            guidQuoteLineMap.put(ql.SAP_Line_Item_GUID__c, ql.Id);
        }
        
        if(guidQuoteLineMap.size() > 0)
        {
            for(Quote_Line_Dimension__c qld : trigger.new)
            {
                if(guidQuoteLineMap.containskey(qld.excel_guid__c))
                    qld.Quote_line__c = guidQuoteLineMap.get(qld.excel_guid__c);
            }
        }
    }
}