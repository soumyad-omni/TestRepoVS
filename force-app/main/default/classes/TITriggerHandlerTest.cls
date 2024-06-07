/**********************************************************************
Name:  TITriggerHandlerTest
======================================================
======================================================
Purpose: 
This is the test class for TITriggerHandler                                                           
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                      DATE             DETAIL                     Description
0.1         Sahid Hussain              8/17/2021      					        INITIAL DEVELOPMENT
***********************************************************************/
@isTest
public class TITriggerHandlerTest {
	public static testmethod void TITriggerHandlerTest(){
        Target_Initiative__c ti = new Target_Initiative__c();
        ti.Name = 'test1';
        ti.Start_Date__c = Date.today();
        ti.End_Date__c = Date.today().addDays(3);
        insert ti;
        Target_Initiative_Opportunity__c tio = new Target_Initiative_Opportunity__c();
        Opportunity opp = TestDataFactory.createOppWithAccount();
        tio.Opportunity__c = opp.Id;
        tio.Target_Initiative__c = ti.Id;
        insert tio;
        Try{
            Test.startTest();
            delete ti;
            Test.stopTest();
        }catch(Exception ee)
		{}        
    }
}