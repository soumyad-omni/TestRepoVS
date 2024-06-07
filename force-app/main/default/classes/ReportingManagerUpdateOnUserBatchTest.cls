@isTest
public with sharing class ReportingManagerUpdateOnUserBatchTest {
    
    @IsTest
    static void methodName1(){
        Reporting_Manager__c rm = new Reporting_Manager__c();
        rm.Reporting_Business_Unit_Manager__c = 'Warren Patterson';
        rm.Reporting_Division_Manager__c = 'Michael Long';
        rm.Reporting_Manager__c = 'Yasser Ahmed Mohamed Abbady Hamed';
        rm.Reporting_Regional_Manager__c = 'Michael Long';
        rm.User__c = UserInfo.getUserId();
        rm.Updated__c = true;
        insert rm;
        Test.startTest();
            String cronTrigger = '0 55 23 L MAR,JUN,SEP,DEC ? *' ;
            System.schedule('ScheduleReportingManagerUpdateOnUserJob',cronTrigger,new ScheduleReportingManagerUpdateOnUserJob());
        Test.stopTest();        
    }
}