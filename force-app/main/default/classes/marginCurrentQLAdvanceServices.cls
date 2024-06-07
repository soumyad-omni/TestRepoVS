global class marginCurrentQLAdvanceServices implements Database.Batchable<sObject>, schedulable
{
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        
        String query = 'SELECT id, expected_booking__c, SAP_Line_Number__c, SAP_Quote_Number__c, Copied_From_Quote_Lines__c  FROM Quote_Line_Backlog__c';
        query = query +' WHERE (expected_booking__c = NULL OR expected_booking__c = 0)';
        query = query +' AND Derived_Portfolio_Segment__c =\'Advanced Services\'';
        if(!Test.isRunningTest()){
            query = query +' AND Valid_From__c <= TODAY ';
        	query = query +' AND Valid_To__c >=TODAY';
        }
        
        //query = query +' AND ID=\'aEJ2300000079XYGAY\'';
        
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Quote_Line_Backlog__c> bklgRslt) 
    {
        List<Quote_Line_Backlog__c> updateQlbList = new List<Quote_Line_Backlog__c>();
        Set<String> quoteNumber = new Set<String>();
        Set<Integer> lineNumber = new Set<Integer>();
        Map<String, Decimal> expectedBookingValue = new Map<String, Decimal>();
        
        for(Quote_Line_Backlog__c bklgData : bklgRslt)
        {
            system.debug('cqlr-->'+bklgData.SAP_Quote_Number__c+'-'+bklgData.SAP_Line_Number__c);
            quoteNumber.add(bklgData.SAP_Quote_Number__c);
            lineNumber.add(Integer.valueof(bklgData.SAP_Line_Number__c));
        }
        if(!quoteNumber.isEmpty() && !lineNumber.isEmpty())
        {
            for(Quote_Line__c ql : [Select id, SAP_Line_Number__c,Quote__r.SAP_Quote_Number_Truncated__c,Line_Expected_Booking__c 
                                             From Quote_Line__c 
                                             Where Line_Expected_Booking__c != 0 
                                             	   AND Line_Expected_Booking__c != null
                                            	   AND Quote__r.SAP_Quote_Number_Truncated__c in :quoteNumber 
                                            	   AND SAP_Line_Number__c in :lineNumber])
            {
                system.debug('qlb-->'+ql.Quote__r.SAP_Quote_Number_Truncated__c+'-'+Integer.valueOf(ql.SAP_Line_Number__c));
                expectedBookingValue.put(ql.Quote__r.SAP_Quote_Number_Truncated__c+'-'+Integer.valueOf(ql.SAP_Line_Number__c),ql.Line_Expected_Booking__c);
                
            }
        }
        for(Quote_Line_Backlog__c bklgData : bklgRslt)
        {
            if(expectedBookingValue.containsKey(bklgData.SAP_Quote_Number__c+'-'+Integer.valueOf(bklgData.SAP_Line_Number__c)))
                {
                    bklgData.expected_booking__c = expectedBookingValue.get(bklgData.SAP_Quote_Number__c+'-'+Integer.valueOf(bklgData.SAP_Line_Number__c));
                     bklgData.Copied_From_Quote_Lines__c = true;
                    updateQlbList.add(bklgData);
                }
        }
        if(!updateQlbList.isEmpty()){
            update updateQlbList;
        }
        
    }
    global void finish(Database.BatchableContext BC) {
        database.executeBatch(new marginQLBacklogAverage(), 50);
    }
    global void execute(SchedulableContext SC) {
        database.executebatch(new marginCurrentQLAdvanceServices());
    }
}