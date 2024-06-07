/***********************************************************************************************************
Name:  AccountContactRelation_Schedule
Copyright © 2018
============================================================================================================
============================================================================================================
Purpose: 
This is schedule class for batch class - AccountContactRelation_Batch
============================================================================================================
=============================================================================================================
History                                                            
-------                                                            
VERSION      AUTHOR                      DATE             DETAIL               Description
0.1          Capgemin Dev Team          10/01/2018                           INITIAL DEVELOPMENT
*************************************************************************************************************/

global class AccountContactRelation_Schedule implements Schedulable {

   global void execute(SchedulableContext ctx) {
        AccountContactRelation_Batch p = new AccountContactRelation_Batch();
        database.executeBatch(p,20);
        system.debug('job done');

   }   
}