/***********************************************************************************************************
Name:  ScheduleAllBkdQuoteProdBSegUdtBatch 
Copyright © 2020
============================================================================================================
============================================================================================================
Purpose: 
The Scheduler calls BCH_AllBKDQuoteProdBSegLineUpdate batch at night to look into Quotes booked in last one day 
and checks if any of them have no Product Lines, it will create Product Lines.

============================================================================================================
=============================================================================================================
History                                                            
-------                                                            
VERSION      AUTHOR                      DATE             DETAIL               Description
0.1          Pabitra Tripathy          11/26/2020        
*************************************************************************************************************/
global class ScheduleAllBkdQuoteProdBSegUdtBatch implements Schedulable {
    
    global void execute(SchedulableContext ctx) {
        BCH_AllBKDQuoteProdBSegLineUpdate bkdAllQtProdSegObj= new BCH_AllBKDQuoteProdBSegLineUpdate();
        Id batchId = Database.executeBatch(bkdAllQtProdSegObj,25);
    }
}