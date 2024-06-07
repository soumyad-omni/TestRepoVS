/***********************************************************************************************************
Name:  BCH_AllBKDQuoteProdBSegLineUpdate
Copyright © 2020
============================================================================================================
============================================================================================================
Purpose: 
The batch job checks historical Quotes booked in last one day, if any of them have no Product Lines, it will create
Product Lines.   

============================================================================================================
=============================================================================================================
History                                                            
-------                                                            
VERSION      AUTHOR                      DATE             DETAIL               Description
0.1          Pabitra Tripathy          11/12/2020        
*************************************************************************************************************/

public class BCH_AllBKDQuoteProdBSegLineUpdate implements 
Database.Batchable<sObject> {
   static final Integer NO_OF_DAYS=365;
    public Database.QueryLocator start(Database.BatchableContext bc) {
        
        String queryBlankProdLines='SELECT Id,Quote_Number__c,Primary_Quote__c,'+
        'Booking_Date__c,OpportunityId,Order_Type__c,Status FROM Quote WHERE ('+
        'Status in( \'E0013\', \'E0014\', \'E0019\') AND Quote.Id NOT IN (SELECT Quote__c FROM '+
        'Product_Line__c))'; 
		
        return Database.getQueryLocator(queryBlankProdLines);
    }
    
    public void execute(Database.BatchableContext bc, List<Quote> bookedQuotesList){
        List<Quote> oldQuote=new List<Quote>();
        
        for(Quote bookedQuote:bookedQuotesList) {    
            List<Quote> quoteList=new List<Quote>();
            quoteList.add(bookedQuote);
            ProdLineSegBSegForPriQuote_Class prodLineObj = new ProdLineSegBSegForPriQuote_Class();
            ProdLineSegBSegForPriQuote_Class.isQuoteUpdated=true;
            prodLineObj.initiateProductUpdates(quoteList,oldQuote); 
        }
    }
 
    public void finish(Database.BatchableContext bc){
    }
}