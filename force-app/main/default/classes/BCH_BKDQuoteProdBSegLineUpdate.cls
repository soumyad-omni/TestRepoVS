/***********************************************************************************************************
Name:  BCH_BKDQuoteProdBSegLineUpdate
Copyright © 2020
============================================================================================================
============================================================================================================
Purpose: 
The batch job checks Quotes booked in last one day, if any of them have no Product Lines, it will create
Product Lines.   

============================================================================================================
=============================================================================================================
History                                                            
-------                                                            
VERSION      AUTHOR                      DATE             DETAIL               Description
0.1          Pabitra Tripathy          11/26/2020        
*************************************************************************************************************/

public class BCH_BKDQuoteProdBSegLineUpdate implements 
Database.Batchable<sObject> {

    static final Integer NO_OF_DAYS=1;
  
    public Database.QueryLocator start(Database.BatchableContext bc) {
        
       String queryBlankProdLines='SELECT q.Id,q.Quote_Number__c,q.Primary_Quote__c,'+
        'q.Booking_Date__c,q.OpportunityId,q.Order_Type__c,q.Status FROM Quote q WHERE ('+
        'q.Status in( \'E0013\', \'E0014\', \'E0019\') and q.Booking_Date__c=LAST_N_DAYS:'+NO_OF_DAYS+' AND '+
        'q.Id NOT IN (SELECT Quote__c FROM Product_Line__c WHERE '+
        'Date_Booked__c=LAST_N_DAYS:'+NO_OF_DAYS+'))';
         
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