public class CaseTriggerHandler implements ITriggerHandler{
    public static boolean TriggerDisabled= false;
    public boolean isDisabled;
    
    public boolean IsDisabled(){
        Trigger_Configuration__c tc = Trigger_Configuration__c.getInstance('CaseTriggerHandler');
        if(tc != null) isDisabled= tc.isDisabled__c;
        if(isDisabled == true)
            return true;
        else
            return TriggerDisabled;
    }
    
    public void beforeInsert(List<SObject> newItems)
    {
        List<Case> caseList = newItems;
        List<String> salesOrderNumbers = new List<String>();
        for(Case cs : caseList)
        {
            if(cs.Sales_Order_Number__c <> NULL && cs.Sales_Order_Number__c <> '')
            {
                salesOrderNumbers.add(cs.Sales_Order_Number__c);
            }
        }
        
        if(!salesOrderNumbers.isEmpty())
        {
            getQuoteIds(salesOrderNumbers, caseList);
        }
    }
    
    public void beforeUpdate(Map<Id, SObject> oldItems, Map<Id, SObject> newItems)
    {
        List<Case> caseList = newItems.values();
        Map<Id, Case> oldMap = new Map<Id, Case>();
        
        for(Id caseId : oldItems.keyset())
        {
            oldMap.put(caseId, (Case)oldItems.get(caseId));
        }
        
        List<String> salesOrderNumbers = new List<String>();
        for(Case cs : caseList)
        {
            if(cs.Sales_Order_Number__c <> NULL && cs.Sales_Order_Number__c <> ''
               && oldMap.get(cs.Id).Sales_Order_Number__c <> cs.Sales_Order_Number__c)
            {
                salesOrderNumbers.add(cs.Sales_Order_Number__c);
            }
        }
        
        if(!salesOrderNumbers.isEmpty())
        {
            getQuoteIds(salesOrderNumbers, caseList);
        }
    }
    
    public void getQuoteIds(List<String> salesOrderNumbers, List<Case> caseList)
    {
        Map<String, Id> quoteIdMap = new Map<String, Id>();
        
        for(Quote qt : [SELECT id, SAP_Sales_Order_Number__c FROM Quote
                       WHERE SAP_Sales_Order_Number__c IN :salesOrderNumbers ])
        {
            quoteIdMap.put(qt.SAP_Sales_Order_Number__c, qt.Id);
        }
        
        for(Case cs : caseList)
        {
            if(quoteIdMap.containsKey(cs.Sales_Order_Number__c))
            {
                cs.Quote__c = quoteIdMap.get(cs.Sales_Order_Number__c);
            }
        }
        
    }
    
    public void beforeDelete(Map<Id, SObject> oldItems)
    {
    }
    
    public void afterInsert(Map<Id, SObject> newItems)
    { 
    }
    
    public void afterUpdate(Map<Id, SObject> oldItems, Map<Id, SObject> newItems)
    {
    }
    
    public void afterDelete(Map<Id, SObject> oldItems)
    {
    }
    
    public void afterUndelete(Map<Id, SObject> oldItems)
    {
    }
}