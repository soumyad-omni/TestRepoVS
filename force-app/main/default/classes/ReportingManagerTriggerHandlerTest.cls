@isTest
public class ReportingManagerTriggerHandlerTest {
	@IsTest
    static void methodName1(){
        List<Reporting_Manager__c> rmList = new List<Reporting_Manager__c>();
        Reporting_Manager__c rm = new Reporting_Manager__c();
        rm.Reporting_Business_Unit_Manager__c = 'Warren Patterson';
        rm.Reporting_Division_Manager__c = 'Michael Long';
        rm.Reporting_Manager__c = 'Yasser Ahmed Mohamed Abbady Hamed';
        rm.Reporting_Regional_Manager__c = 'Michael Long';
        rm.User__c = UserInfo.getUserId();
        rm.Updated__c = true;  
        rmList.add(rm);
        Reporting_Manager__c rm2 = new Reporting_Manager__c();
        rm2.Reporting_Business_Unit_Manager__c = 'Warren Patterson';
        rm2.Reporting_Division_Manager__c = 'Michael Long';
        rm2.Reporting_Manager__c = 'Yasser Ahmed Mohamed Abbady Hamed';
        rm2.Reporting_Regional_Manager__c = 'Michael Long';
        rm2.User__c = UserInfo.getUserId();
        rm2.Updated__c = true;  
        rmList.add(rm2);
        Reporting_Manager__c rm3 = new Reporting_Manager__c();
        rm3.Reporting_Business_Unit_Manager__c = 'Warren Patterson';
        rm3.Reporting_Division_Manager__c = 'Michael Long';
        rm3.Reporting_Manager__c = 'Yasser Ahmed Mohamed Abbady Hamed';
        rm3.Reporting_Regional_Manager__c = 'Michael Long';
        rm3.User__c = UserInfo.getUserId();
        rm3.Updated__c = true;  
        rmList.add(rm3);
        Test.startTest();
            try{
                insert rmList;
            }
            catch(Exception e){
                
            }            
        Test.stopTest();        
    }
    
    @IsTest
    static void methodName2(){
        List<Reporting_Manager__c> rmList = new List<Reporting_Manager__c>();
        Reporting_Manager__c rm = new Reporting_Manager__c();
        rm.Reporting_Business_Unit_Manager__c = 'Warren Patterson';
        rm.Reporting_Division_Manager__c = 'Michael Long';
        rm.Reporting_Manager__c = 'Yasser Ahmed Mohamed Abbady Hamed';
        rm.Reporting_Regional_Manager__c = 'Michael Long';
        rm.User__c = UserInfo.getUserId();
        rm.Updated__c = true;  
        rmList.add(rm);
        Reporting_Manager__c rm2 = new Reporting_Manager__c();
        rm2.Reporting_Business_Unit_Manager__c = 'Warren Patterson';
        rm2.Reporting_Division_Manager__c = 'Michael Long';
        rm2.Reporting_Manager__c = 'Yasser Ahmed Mohamed Abbady Hamed';
        rm2.Reporting_Regional_Manager__c = 'Michael Long';
        rm2.User__c = UserInfo.getUserId();
        rm2.Updated__c = true;  
        rmList.add(rm2);
        ReportingManagerTriggerHandler.TriggerDisabled = true;
        insert rmList;
        ReportingManagerTriggerHandler.TriggerDisabled = false;
        Test.startTest();
            try{
                rm2.Reporting_Business_Unit_Manager__c = 'Joseph Manni';
                update rm2;
            }
            catch(Exception e){
                
            }            
        Test.stopTest();        
    }
}