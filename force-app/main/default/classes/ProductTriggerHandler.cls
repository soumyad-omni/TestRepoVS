Public with sharing class ProductTriggerHandler {
    Public Static void beforeupdatemethod(Map<Id, Product2> newMap, Map<Id, Product2> oldMap){
        List<Product2> NewLst = newMap.values();
        List<Product2> OldLst = oldMap.values();
        
        Run_Product_line_Update__c rpl = [select id,Run_Product_line_Update__c from Run_Product_line_Update__c where name = 'Run Product line Update'];
        
        for( Id prodid : newMap.keySet() )
        {
          
          if( oldMap.get( prodid ).DW_Product_Line__c != newMap.get( prodid ).DW_Product_Line__c )
          {
             newMap.get( prodid ).Segment_Changed__c = true;
             rpl.Run_Product_line_Update__c = true;
          }
          if( oldMap.get( prodid ).Portfolio_Segment__c != newMap.get( prodid ).Portfolio_Segment__c )
          {
             newMap.get( prodid ).Segment_Changed__c = true;
             rpl.Run_Product_line_Update__c = true;
          }
        }
        if(rpl.Run_Product_line_Update__c == true){
            update rpl;
        }
    }
}