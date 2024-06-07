/***********************************************************************************************************
Name:  ScheduleBkdQuoteProdBSegUdtBatch 
Copyright © 2020
============================================================================================================
============================================================================================================
Purpose: 
The Scheduler calls BCH_BKDQuoteProdBSegLineUpdate batch at night to look into Quotes booked in last one day 
and checks if any of them have no Product Lines, it will create Product Lines.

============================================================================================================
=============================================================================================================
History                                                            
-------                                                            
VERSION      AUTHOR                      DATE             DETAIL               Description
0.1          Pabitra Tripathy          11/26/2020        
*************************************************************************************************************/
global class ScheduleBkdQuoteProdBSegUdtBatch implements Schedulable {
    
    global void execute(SchedulableContext ctx) {
        BCH_BKDQuoteProdBSegLineUpdate bkdQtProdSegObj= new BCH_BKDQuoteProdBSegLineUpdate();
        Id batchId = Database.executeBatch(bkdQtProdSegObj);
    }
}