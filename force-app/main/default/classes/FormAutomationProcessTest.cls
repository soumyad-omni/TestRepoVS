/**********************************************************************
Name:  FormAutomationProcessTest
======================================================
======================================================
Purpose: 
This is the test class for FormAutomationProcess                                                           
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                      DATE             DETAIL                     Description
0.1         Pritha Nandi               02/03/2022                                INITIAL DEVELOPMENT
***********************************************************************/
@isTest
public class FormAutomationProcessTest {
    
		   @isTest static void test() {
       			 Test.StartTest();
 				AccountCreateController.isFirstRun= false;
       			 Account acc1 = TestDataFactory.createTestAccountQuotePrint();
               	List<PAR_Location__c> parloc =TestDataFactory.createParLocation(acc1);
               List<string> parlocationId= new List<String>();
               for(PAR_Location__c p: parloc){
                   parlocationId.add(p.Id);
               }
               FormAutomationProcess.createForm(parlocationId);
           }
}